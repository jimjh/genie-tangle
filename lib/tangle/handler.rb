# ~*~ encoding: utf-8 ~*~
require 'tangle/support/traceable'

module Tangle

  # Provides implementation for the RPC interface. Refer to `tangle.thrift` for
  # details.
  class Handler

    include Support::Traceable

    attr_reader :started

    def initialize
      @started = Time.now
    end

    # @return [String] 'pong!'
    def ping
      log_invocation
      'pong!'
    end

    # @return [TangleInfo] basic information about Tangle
    def info
      log_invocation
      TangleInfo.new uptime: uptime, threads: threads
    end

    # Creates a new SSH channel.
    #
    # If a SSH connection to a VM of the requested VM class for the given user
    # already exists, a new channel is created on the connection. Otherwise, a
    # new connection is opened. Output from the channel are sent on the output
    # channel.
    #
    # @param  [String] user_id
    # @param  [String] vm_class
    # @param  [String] output
    # @return [String] path to input pipe
    #
    # @todo TODO use user_id, vm_class
    # @todo TODO reuse
    # @todo TODO should the hash table be persistent?
    def ssh(user_id, vm_class, output)
      Net::SSH.start 'beta.geniehub.org', 'passenger' do |ssh|
        channel = ssh.open_channel do |ch|
          ch.request_pty do |ch, success|
            ch.exec "/usr/bin/vim" do |ch, success|
              ch.send_data "ixkcd\033:w! wow.txt\n"
              ch.send_data ":q\n"
              ch.send_data "logout\n"
            end
          end
          ch.on_data { |c, d| puts d }
          ch.on_extended_data { |c, d| puts d }
          ch.on_close { puts "Connection closed." }
        end
        ssh.loop { channel.active? }
      end
    end

    private

    # @return [Hash] number of threads (+'total'+ and +'running'+)
    def threads
      { 'total'   => Thread.list.count,
        'running' => Thread.list.map(&:status).grep('run').count
      }
    end

    # @return [Float] number of seconds since server launch
    def uptime
      Time.now - started
    end

    # Logs the caller of this method.
    def log_invocation
      if Tangle.logger.debug?
        Tangle.logger.debug 'rpc -> ' + caller[0][/`([^']*)'/, 1]
      end
    end

  end

end
