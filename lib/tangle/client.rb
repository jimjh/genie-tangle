require 'tangle/config'
require 'tangle/gen'

module Tangle

  # Contains, configures, and controls the Thrift RPC client.
  #
  # @example Ping Pong
  #     client.transport.open
  #     client.ping # => 'pong!'
  #     client.transport.close
  #
  # @note This is patched into the generated client class.
  class Client

    attr_reader :host, :port, :transport, :logger

    # @option opts [String] host ('::1')       host
    # @option opts [String] port               port number (required)
    def initialize(opts={})
      @host = opts[:host] || HOST
      @port = opts[:port] || raise(ArgumentError, ':port is a required option')
      @logger   = opts[:logger]
      socket     = Thrift::Socket.new host, port
      @transport = Thrift::BufferedTransport.new socket
      protocol   = Thrift::BinaryProtocol.new @transport
      super protocol
    end

    # Invokes given block within an open transport.
    def invoke
      transport.open
      yield self
    rescue => e
      logger.error e.message if logger
      raise e
    ensure
      transport.close
    end

    private

    def logger
      @logger || ( Tangle.respond_to?(:logger) ? Tangle.logger : nil )
    end

  end

end
