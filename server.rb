#!/usr/bin/env ruby
# ~*~ encoding: utf-8 ~*~

$:.push './gen'
require 'thrift'
require 'judge'

class JudgeHandler
  def ping
    'pong!'
  end
end

handler   = JudgeHandler.new
processor = Judge::Processor.new(handler)
transport = Thrift::ServerSocket.new(9090) # TODO: make configurable
transportFactory = Thrift::BufferedTransportFactory.new

# TODO: use other subclasses of BaseServer?
server    = Thrift::SimpleServer.new(processor, transport, transportFactory)
puts 'Starting the Judge service ...'
server.serve()
puts 'done.'
