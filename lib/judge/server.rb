# ~*~ encoding: utf-8 ~*~
require 'judge/handler'
module Judge

  # Contains, configures, and controls the Thrift RPC server.
  class Server

    attr_reader :port, :socket, :thread

    # Defaults to an ephemeral port
    DEFAULT_PORT = 0

    # Number of seconds to wait while server is starting up
    SPIN = 0.1

    # TODO: use other subclasses of BaseServer?
    # @option opts [Fixnum] port     port number
    def initialize(opts={})
      @port     = opts['port'] || DEFAULT_PORT
      @socket   = Thrift::ServerSocket.new('::1', port)
      processor = Processor.new Handler.new
      factory   = Thrift::BufferedTransportFactory.new
      @server   = Thrift::ThreadPoolServer.new(processor, socket, factory)
    end

    # Starts the Thrift RPC server and returns the server thread. Note that
    # while the server may spawn new threads, the returned thread completes
    # only after the server has stopped.
    # @return [Thread] thread         main thread for RPC server
    def serve
      Judge.logger.info 'Starting the Judge service ...'
      @thread = Thread.new { @server.serve }
      sleep SPIN while @thread.alive? and not socket.handle # FIXME
      @port = socket.handle.addr[1] and Judge.logger.info status if @thread.alive?
      @thread
    end

    # @return [String] status message
    def status
      if @thread.alive?
        if socket.handle then "Judge is listening on port #{port}."
        else 'Judge is starting up.'
        end
      else 'Judge has stopped.'
      end
    end

  end

end
