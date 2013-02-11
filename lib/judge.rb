# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'pry'
require 'bunny'
require 'active_support/core_ext/logger'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'judge'

require 'judge/config'
require 'judge/errors'
require 'judge/server'
require 'judge/manager'
require 'judge/client'

module Judge
  class << self

    attr_accessor :logger, :bunny

    # @option opts [String] log-file  ({Judge::LOG_FILE})
    # @option opts [String] log-level ({Judge::LOG_LEVEL})
    def reset_logger(opts={})
      @logger = Logger.new(opts['log-file'] || LOG_FILE)
      @logger.level     = opts['log-level'] || LOG_LEVEL
      @logger.formatter = Logger::Formatter.new
      @logger.info "Judge v#{VERSION}"
    end

    # Opens TCP connection to RabbitMq.
    def reset_bunny(opts={})
      optz = { logfile: opts['log-file'] || LOG_FILE }
      @bunny   = Bunny.new BUNNY_OPTS.merge optz
      @bunny.start # open TCP connection
    rescue Bunny::TCPConnectionFailed
      raise Judge::Abort, 'Unable to connect to RabbitMq. The given options were: ' +
        RABBIT_JOBS.queue[:opts].inspect
    rescue Bunny::PossibleAuthenticationFailureError
      raise Judge::Abort, "Could not authenticate as #{@bunny.username}."
    end

    # Starts a RPC server. See {Judge::Server} for options.
    # @return [void]
    def server(opts={})
      reset_logger opts
      reset_bunny  opts
      t = Server.new(opts).serve
      Manager.new.manage
      t.value
    rescue Interrupt
      logger.info 'Court adjourned.'
    end

    # Starts a client and invokes the given command. If a command is not
    # provided, starts a pry console. See {Judge::Client} for options.
    # @param [String] cmd       RPC command to invoke
    # @param [Array]  argv      parameters for command
    # @return [void]
    def client(cmd=nil, argv=[], opts={})
      reset_logger opts
      client = Client.new(opts)
      results = if cmd.nil? then client.invoke { pry }
      else client.invoke { public_send(cmd, *argv) }
      end
      logger.info "Response: #{results.inspect}"
    end

  end
end
