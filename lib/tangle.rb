require 'thrift'
require 'faye'
require 'pry'
require 'active_support/core_ext/logger'

require 'tangle/version'
require 'tangle/config'
require 'tangle/errors'
require 'tangle/secrets'
require 'tangle/server'
require 'tangle/client'
require 'tangle/tty_extension'

module Tangle
  class << self

    attr_reader :logger, :faye

    # @option opts [String] log-file  ({Tangle::LOG_FILE})
    # @option opts [String] log-level ({Tangle::LOG_LEVEL})
    def reset_logger(opts={})
      @logger = Logger.new(opts['log-file'] || LOG_FILE)
      @logger.level     = opts['log-level'] || LOG_LEVEL
      @logger.formatter = Logger::Formatter.new
      @logger.info "Tangle v#{VERSION} [#{ENV['RACK_ENV']}]"
      Faye.logger = @logger.method(:info)
      EM.error_handler { |e| logger.error e }
    end

    # Starts a RPC server. See {Tangle::Server} for options.
    # @todo TODO move faye to child process
    # @todo TODO allow configuration of faye server
    # @return [void]
    def server(opts={})
      reset_logger opts
      thrift = Server.new(opts).serve
      Thread.new do
        faye.listen(opts['faye-port'] || FAYE_PORT)
        thrift.raise(Interrupt)
      end
      thrift.value
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
      results = if cmd.nil? then client.invoke { |c| c.pry }
      else client.invoke { |c| c.public_send(cmd, *argv) }
      end
      logger.info "Response: #{results.inspect}"
    end

    def faye
      @faye ||= Faye::RackAdapter.new mount: '/socket',
        timeout: 25,
        extensions: [TTY::Extension.new]
    end

  end
end
