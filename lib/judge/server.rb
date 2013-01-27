# ~*~ encoding: utf-8 ~*~
require 'judge/handler'
module Judge

  # Contains, configures, and controls the Thrift RPC server.
  class Server

    DEFAULT_PORT = 9090

    # TODO: use other subclasses of BaseServer?
    # @option opts [Fixnum] port     port number
    def initialize(opts={})
      port = opts[:port] || DEFAULT_PORT
      processor = Processor.new Handler.new
      transport = Thrift::ServerSocket.new(port)
      transportFactory = Thrift::BufferedTransportFactory.new
      @server    = Thrift::SimpleServer.new(processor, transport, transportFactory)
    end

    # TODO: logging
    def serve
      puts 'Starting the Judge service ...'
      @server.serve
    end

  end

end
