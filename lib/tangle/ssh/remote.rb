require 'aws-sdk'
require 'openssl'

module Tangle::SSH
  class Remote < Base

    PRIVATE_KEY = File.expand_path('../../../config/tangle.pem', __dir__).freeze
    EC2_TAG     = 'tangle-vms'
    SSH_RETRY_PERIOD = 10 # in seconds

    attr_accessor :retries
    attr_reader   :unix_user, :unix_pass

    def initialize(opts={})
      @retries   = 0
      @unix_user = unix_user_for opts[:owner]
      @unix_pass = unix_pass_for opts[:owner]
      super opts
    end

    def open(opts={})
      vm = pick_vm
      open_vm vm, opts
    end

    private

    # @param  [String] owner       user ID
    # @return [String] generated UNIX user name
    def unix_user_for(owner)
      # use the first 24 bytes
      OpenSSL::HMAC.hexdigest('SHA1', Tangle::Secrets['UNIX_USER_SECRET'], owner)[0,12]
    end

    # @param  [String] owner       user ID
    # @return [String] generated UNIX user password
    def unix_pass_for(owner)
      OpenSSL::HMAC.hexdigest('SHA256', Tangle::Secrets['UNIX_USER_SECRET'], owner)
    end

    # Pick an existing VM or launch a new instance.
    # @return [AWS::EC2::Instance] vm
    def pick_vm
      vms.detect { |i| i.status == :running } || launch_vm
    end

    # Starts a SSH session to the given VM.
    def open_vm(vm, opts)
      ensure_unix_user_exists_on vm do
        start_user_session_on vm, opts
      end
    end

    def ensure_unix_user_exists_on(vm)
      logger.info "[tty] initiating SSH session with #{vm.id} as `ubuntu`"
      opts = ssh_opts.merge(keys: [PRIVATE_KEY])
      EM::Ssh.start vm.dns_name, 'ubuntu', opts do |session|
        session.errback do |err|
          logger.error "#{err} (#{err.class})"
          logger.info  "[tty] session closed <x> #{vm.id}"
          retry? ? _retry { ensure_unix_user_exists_on vm } : close
        end
        session.callback do |ssh|
          logger.info "[tty] session started <-> #{vm.id}"
          ssh.open_channel do |channel|
            channel.exec("./ensure_user_exists.sh #{unix_user}") do |ch|
              channel.on_data { |_, data| logger.info "[ssh] #{data}" }
              channel.on_extended_data { |_, data| logger.info "[ssh] #{data}" }
              channel.send_data unix_pass
              channel.eof!
            end
          end.wait
          ssh.close
          block_given? ? yield : close
        end
      end
    end

    def start_user_session_on(vm, opts)
      options = ssh_opts
      options[:auth_methods] << 'password'
      options[:password] = unix_pass
      EM::Ssh.start vm.dns_name, unix_user, options do |session|
        session.errback  do |err|
          logger.error "#{err} (#{err.class})"
          logger.info  "[tty] session closed <x> #{unix_user}@#{vm.id}"
          close
        end
        session.callback do |ssh|
          logger.info "[tty] session started <-> #{unix_user}@#{vm.id}"
          open_channel(ssh, opts).wait
          ssh.close
          logger.info "[tty] session closed <x> #{unix_user}@#{vm.id}"
          close
        end
      end
    end

    # @return [Boolean] true iff should retry attempt
    def retry?
      retries > 0
    end

    def _retry
      self.retries = retries - 1
      back_off = 5 + Random.rand(SSH_RETRY_PERIOD)
      logger.info "[tty] retrying after #{back_off} seconds"
      sleep back_off
      yield
    end

    # Retrieves collection of existing instances.
    # @return [AWS::EC2::InstanceCollection] vms
    def vms
      @vms ||= ec2.instances.tagged EC2_TAG
    end

    # @return [AWS::EC2::Instance] vm
    def launch_vm
      logger.info "[tty] launching new EC2 instance"
      vm = ec2.instances.create vm_opts
      vm.tag EC2_TAG
      sleep 2 while vm.status == :pending
      logger.info "[tty] #{vm.id} is ready"
      self.retries = retries + 2
      vm
    end

    def ec2
      @ec2 ||= AWS::EC2.new
    end

    def ssh_opts
      {
        logger:       logger,
        auth_methods: %w[publickey]
      }
    end

    def vm_opts
      {
        image_id: 'ami-e995e380',
        key_name: 'tangle',
        security_groups: 'tangle-vms',
        instance_type: 't1.micro',
      }
    end

  end
end
