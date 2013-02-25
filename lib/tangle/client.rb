# ~*~ encoding: utf-8 ~*~
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

    attr_reader :host, :port, :transport

    # @option opts [String] host ('::1')       host
    # @option opts [String] port               port number (required)
    def initialize(opts={})
      @host = opts['host'] || HOST
      @port = opts['port'] || raise(ArgumentError, ':port is a required option')
      socket     = Thrift::Socket.new host, port
      @transport = Thrift::BufferedTransport.new socket
      protocol   = Thrift::BinaryProtocol.new @transport
      super protocol
    end

    # Invokes given block within an open transport.
    def invoke(&block)
      @transport.open
      instance_eval(&block)
    rescue => e
      Tangle.logger.error e.message
    ensure
      @transport.close
    end

  end

end
