#!/usr/bin/env ruby
# ~*~ encoding: utf-8 ~*~

$:.push './gen'
require 'thrift'
require 'judge'

begin

  transport = Thrift::BufferedTransport.new(Thrift::Socket.new('127.0.0.1', 9090))
  protocol = Thrift::BinaryProtocol.new(transport)
  client   = Judge::Client.new(protocol)

  transport.open
  result = client.ping
  transport.close

  puts result.inspect

rescue
  puts $!
end
