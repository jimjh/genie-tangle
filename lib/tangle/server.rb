require 'tangle/gen'
require 'tangle/handler'

module Tangle

  # Contains, configures, and controls the Thrift RPC server.
  class Server

    attr_reader :port, :socket, :thread, :logger

    # Number of seconds to wait while server is starting up
    SPIN = 0.1

    # @option opts [Fixnum] port     port number
    def initialize(opts={})
      @logger   = opts[:logger] || Tangle.logger || raise(ArgumentError, ':logger is required')
      @port     = opts[:port]   || PORT
      logger.info 'Initializing Tangle server ...'
      @socket   = Thrift::ServerSocket.new('localhost', port)
      processor = Processor.new Handler.new(logger: logger)
      factory   = Thrift::BufferedTransportFactory.new
      @server   = Thrift::ThreadPoolServer.new(processor, socket, factory)
    end

    # Starts the Thrift RPC server and returns the server thread. Note that
    # while the server may spawn new threads, the returned thread completes
    # only after the server has stopped.
    # @return [Thread] thread         main thread for RPC server
    def serve
      logger.info 'Starting Tangle service ...'
      @thread = Thread.new { @server.serve }
      sleep SPIN while @thread.alive? and not socket.handle
      @port = socket.handle.addr[1] and logger.info(status) if @thread.alive?
      @thread
    end

    # @return [String] status message
    def status
      if @thread.alive?
        if socket.handle then "Tangle is listening on port #{port}."
        else 'Tangle is starting up.'
        end
      else 'Tangle has stopped.'
      end
    end

  end

end
