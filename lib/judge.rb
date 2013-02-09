# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'pry'
require 'active_support/core_ext/logger'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'judge'

require 'judge/config'
require 'judge/server'
require 'judge/client'

module Judge
  class << self

    attr_accessor :logger

    def reset_logger(opts={})
      @logger = Logger.new(opts['log-file'] || LOG_FILE)
      @logger.level     = opts['log-level'] || LOG_LEVEL
      @logger.formatter = Logger::Formatter.new
    end

    # Starts a RPC server.
    def server(opts={})
      reset_logger opts
      Server.new(opts).serve.value
    rescue Interrupt
      logger.info 'Court adjourned.'
    end

    # Starts a client and invokes the given command. If a command is not
    # provided, starts a pry console.
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
