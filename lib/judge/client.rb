# ~*~ encoding: utf-8 ~*~
module Judge

  # Contains, configures, and controls the Thrift RPC client.
  # @note This is patched into the generated client class.
  class Client

    # Host defaults to localhost
    DEFAULT_HOST = '::1'

    attr_reader :host, :port

    # @option opts [String] host ('::1')       host
    # @option opts [String] port               port number (required)
    def initialize(opts={})
      @host = opts['host'] || DEFAULT_HOST
      @port = opts['port'] || raise(ArgumentError, ':port is a required option')
      socket     = Thrift::Socket.new host, port
      @transport = Thrift::BufferedTransport.new socket
      protocol   = Thrift::BinaryProtocol.new @transport
      super protocol
    end

    # Invokes given block within an open transport.
    # @yieldparam [Client] self       the current instance
    def __invoke__
      @transport.open
      yield self
    rescue => e
      Judge.logger.error e.message
    ensure
      @transport.close
    end

  end

end
