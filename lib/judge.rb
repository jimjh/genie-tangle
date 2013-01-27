# ~*~ encoding: utf-8 ~*~
require 'thrift'
require 'pathname'
require 'active_support/core_ext/logger'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'judge'

require 'judge/server'

module Judge
  class << self

    attr_accessor :logger

    def reset_logger(opts={})
      @logger = Logger.new(opts['output'] || STDOUT)
      @logger.formatter = Logger::Formatter.new
    end

    # Starts a RPC server.
    def server(opts={})
      reset_logger opts
      Server.new(opts).serve.value
    rescue Interrupt
      logger.info 'Court adjourned.'
    end

  end
end
