# ~*~ encoding: utf-8 ~*~
require 'pathname'
require 'thrift'
require 'pry'
require 'active_support/core_ext/logger'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'tangle'

require 'tangle/config'
require 'tangle/errors'
require 'tangle/server'
require 'tangle/client'

module Tangle
  class << self

    attr_accessor :logger

    # @option opts [String] log-file  ({Tangle::LOG_FILE})
    # @option opts [String] log-level ({Tangle::LOG_LEVEL})
    def reset_logger(opts={})
      @logger = Logger.new(opts['log-file'] || LOG_FILE)
      @logger.level     = opts['log-level'] || LOG_LEVEL
      @logger.formatter = Logger::Formatter.new
      @logger.info "Tangle v#{VERSION}"
    end

    # Starts a RPC server. See {Tangle::Server} for options.
    # @return [void]
    def server(opts={})
      reset_logger opts
      Server.new(opts).serve.value
    rescue Interrupt
      logger.info 'Untangled.'
    end

    # Starts a client and invokes the given command. If a command is not
    # provided, starts a pry console. See {Tangle::Client} for options.
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
