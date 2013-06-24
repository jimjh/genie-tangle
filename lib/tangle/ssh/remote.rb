require 'aws-sdk'

module Tangle::SSH
  class Remote < Base

    PRIVATE_KEY = File.expand_path('../../../config/tangle.pem', __dir__).freeze
    EC2_TAG     = 'tangle-vms'
    SSH_RETRY_PERIOD = 10 # in seconds

    attr_accessor :retries

    def initialize(opts={})
      @retries = 0
      super opts
    end

    def open(opts={})
      vm = pick_vm
      open_vm vm, opts
    end

    private

    # Pick an existing VM or launch a new instance.
    # @return [AWS::EC2::Instance] vm
    def pick_vm
      vms.detect { |i| i.status == :running } || launch_vm
    end

    # Starts a SSH session to the given VM.
    def open_vm(vm, opts)
      logger.info "[tty] initiating SSH session with #{vm.id}"
      EM::Ssh.start vm.dns_name, 'ubuntu', ssh_opts do |session|
        session.errback  do |err|
          logger.error "#{err} (#{err.class})"
          logger.info  "[tty] session closed <x> #{vm.id}"
          retry? ? _retry { open_vm vm, opts } : close
        end
        session.callback do |ssh|
          logger.info "[tty] session started <-> #{vm.id}"
          open_channel(ssh, opts).wait
          ssh.close
          logger.info "[tty] session closed <x> #{vm.id}"
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
        keys:         [PRIVATE_KEY],
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
