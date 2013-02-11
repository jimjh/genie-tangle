# ~*~ encoding: utf-8 ~*~
require 'judge/support/traceable'
require 'judge/support/bunniable'

module Judge

  # Provides implementation for the RPC interface. Refer to `judge.thrift` for
  # details.
  class Handler

    include Support::Traceable
    include Support::Bunniable

    attr_reader :started

    def initialize
      @started = Time.now # keep track of start time
      @serializer = Thrift::Serializer.new
      channel.queue RABBIT_JOBS.queue[:name], RABBIT_JOBS.queue[:opts]
    end

    # @return [String] 'pong!'
    def ping
      log_invocation
      'pong!'
    end

    # @return [JudgeInfo] basic information about Judge
    def info
      log_invocation
      JudgeInfo.new uptime: uptime, threads: threads
    end

    # Validates and adds a job to the job queue.
    # @param  [JudgeJob] job
    # @return [Status] success if job is valid, and failure (with trace)
    #   otherwise.
    # @todo FIXME I think the broker silently drops the message on failure
    def add_job(job, reply_to, identifier)
      log_invocation
      status = validate_job job
      if StatusCode::SUCCESS == status.code
        opts = RABBIT_JOBS.message[:opts].merge({
          timestamp: Time.now.to_i,
          reply_to:  reply_to,
          message_id: identifier
        })
        exchange.publish serializer.serialize(job), opts
        Judge.logger.info { 'add_job --[%s]--> %s' % [identifier, RABBIT_JOBS.queue[:name]] }
      end
      status
    rescue => e # for some reason thrift doesn't log errors
      Judge.logger.error 'add_job: ' + e.message
      raise e
    end

    private

    attr_reader :serializer

    # Validates fields in submitted job.
    # @return [Status]
    def validate_job(job)

      job.errors    = 0
      job.trace   ||= []
      job.fsize   ||= MAX_OUTPUT_FILE_SIZE
      job.timeout ||= RUNJOB_TIMEOUT

      validate_name   job
      validate_output job
      validate_inputs job

      if job.errors.zero? then Status.new code: StatusCode::SUCCESS
      else
        Judge.logger.error 'validate_job: Job rejected with %d errors' % job.errors
        job.trace << trace('Job rejected with %d errors' % job.errors)
        Status.new code: StatusCode::FAILURE, trace: job.trace
      end

    end

    # Checks that job has a name.
    def validate_name(job)
      if job.name.empty?
        Judge.logger.error 'validate_job: Missing job.name'
        job.trace << trace('Missing job.name')
        job.errors += 1
      end
    end

    # Checks that job has a valid output file.
    def validate_output(job)
      if job.output.empty?
        Judge.logger.error 'validate_job: Missing job.output'
        job.trace << trace('Missing job.output')
        job.errors += 1
      elsif not Pathname.new(job.output).parent.exist?
        Judge.logger.error 'validate_job: Bad output path: %s' % job.output
        job.trace << trace('Bad output path: %s' % job.output)
        job.errors += 1
      end
    end

    # Checks that job has valid input files.
    def validate_inputs(job)
      if job.inputs.empty?
        Judge.logger.error 'validate_job: Missing job.inputs'
        job.trace << trace('Missing job.inputs')
        job.errors += 1
      else job.inputs.each { |input| validate_input(job, input) }
      end
    end

    # Checks that job has valid input file.
    def validate_input(job, input)
      if input.local.empty?
        Judge.logger.error 'validate_job: Missing job.input.local'
        job.trace << trace('Missing job.input.local')
        job.errors += 1
      elsif not Pathname.new(input.local).exist?
        Judge.logger.error 'validate_job: Bad input path: %s' % input.local
        job.trace << trace('Bad input path: %s' % input.local)
        job.errors += 1
      end
    end

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
        Judge.logger.debug 'rpc -> ' + caller[0][/`([^']*)'/, 1]
      end
    end

  end

end
