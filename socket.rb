#!/usr/bin/env ruby
require 'socket'

puts RUBY_ENGINE

@timeout = 5
@host = ARGV.shift
@port = ARGV.shift

addrinfo = ::Socket::getaddrinfo(@host, @port, nil, ::Socket::SOCK_STREAM).first
@handle = ::Socket.new(addrinfo[4], ::Socket::SOCK_STREAM, 0)
@handle.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1)
sockaddr = ::Socket.sockaddr_in(addrinfo[1], addrinfo[3])

begin
  @handle.connect_nonblock(sockaddr)
rescue Errno::EINPROGRESS
  unless IO.select(nil, [ @handle ], nil, @timeout)
    raise "Connection timeout."
  end
  begin
    @handle.connect_nonblock(sockaddr)
    puts IO.select(nil, [ @handle ], nil, @timeout)
  rescue
    puts IO.select(nil, [ @handle ], nil, @timeout)
  end
end
