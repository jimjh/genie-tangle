require 'tangle/support/traceable'
require 'tangle/tty'

module Tangle

  # Provides implementation for the RPC interface. Refer to `tangle.thrift` for
  # details.
  class Handler
    include Support::Traceable

    attr_reader :started, :logger

    def initialize(logger: nil)
      @logger  = logger || raise(ArgumentError, ':logger is required')
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
      TangleInfo.new uptime: uptime, threads: threads, terminals: TTY.count
    end

    # Creates a new SSH channel.
    #
    # If a SSH connection to a VM of the requested VM class for the given user
    # already exists, a new channel is created on the connection. Otherwise, a
    # new connection is opened. I/O is carried out using faye channels after
    # the connection is opened.
    #
    # @param  [String] user_id      ID of user requesting VM access
    # @param  [String] vm_class     Type of VM to allocate (currently ignored.)
    #
    # @todo TODO use vm_class
    # @return [Fixnum] terminal ID
    def ssh(user_id, vm_class)
      log_invocation
      TTY.create(user_id).object_id
    rescue => e
      logger.error e
      raise e
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
      if logger.debug?
        logger.debug 'rpc -> ' + caller[0][/`([^']*)'/, 1]
      end
    end

  end

end
