#! /usr/bin/env ruby
# ~*~ encoding: utf-8 ~*~

require 'net/ssh'
require 'pry'
require 'socket'
require 'thread'

File.unlink 'xkcd.sock' if File.exists? 'xkcd.sock'
$server = UNIXServer.new 'xkcd.sock'
trap('EXIT') { puts 'Exiting...'; $server.close }

# start separate thread for SSH
#Thread.new do
  Net::SSH.start 'beta.geniehub.org', 'passenger' do |session|
    puts "Session started."
    channel = session.open_channel do |ch|
      puts "Channel opened."
      ch.on_data { |c, d| puts d }
      ch.on_extended_data { |c, d| puts d }
      ch.on_close { puts "Connection closed." }
      ch.request_pty do |ch, success|
        ch = ch.send_channel_request 'shell' do |sh, success|
          puts "Shell opened."
        end
      end
    end
    session.listen_to($server) { |server|
      socket = server.accept_nonblock
      puts "Connection opened."
      socket.extend(Net::SSH::BufferedIo)
      session.listen_to(socket) { |io|
        io.fill
        data = io.read_available
        if data
          channel.send_data data
        else
          session.stop_listening_to socket
          socket.close
        end
      }
    }
    session.loop { channel.active? }
  end
#end
