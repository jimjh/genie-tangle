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
    def ssh(user_id, vm_class, output)
      # TODO
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
