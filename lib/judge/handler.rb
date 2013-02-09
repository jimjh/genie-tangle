# ~*~ encoding: utf-8 ~*~
module Judge

  # Provides implementation for the RPC interface.
  class Handler

    attr_accessor :started

    def initialize
      @started = Time.now # keep track of start time
    end

    # @return [String] 'pong!'
    def ping
      log_invocation
      'pong!'
    end

    # @return [JudgeInfo] basic information about Judge
    def info
      log_invocation
      JudgeInfo.new \
        uptime:  uptime,
        threads: threads
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
      if Judge.logger.debug?
        Judge.logger.debug 'Received RPC call: ' + caller[0][/`([^']*)'/, 1]
      end
    end

  end

end
