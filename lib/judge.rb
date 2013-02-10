# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'pry'
require 'active_support/core_ext/logger'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'judge'

require 'judge/version'
require 'judge/config'
require 'judge/errors'
require 'judge/server'
require 'judge/client'

module Judge
  class << self

    attr_accessor :logger

    # @option opts [String] log-file  ({Judge::LOG_FILE})
    # @option opts [String] log-level ({Judge::LOG_LEVEL})
    def reset_logger(opts={})
      @logger = Logger.new(opts['log-file'] || LOG_FILE)
      @logger.level     = opts['log-level'] || LOG_LEVEL
      @logger.formatter = Logger::Formatter.new
    end

    # Starts a RPC server. See {Judge::Server} for options.
    # @return [void]
    def server(opts={})
      reset_logger opts
      Judge.logger.info "Judge v#{VERSION}"
      Server.new(opts).serve.value
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
