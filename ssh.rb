#! /usr/bin/env ruby
# ~*~ encoding: utf-8 ~*~

require 'net/ssh'
require 'pry'
require 'mkfifo'

ssh = Net::SSH.start 'beta.geniehub.org', 'passenger'

channel = ssh.open_channel do |ch|

  ch.request_pty do |ch, success|
    ch.send_channel_request 'shell' do |ch, success|
      File.mkfifo 'xkcd.pipe'
      Thread.new do
        File.open 'xkcd.pipe' do |f|
          ch.send_data input while input = f.read
        end
      end
    end
  end

  ch.on_data { |c, d| puts d }
  ch.on_extended_data { |c, d| puts d }
  ch.on_close { puts "Connection closed." }

end

ssh.loop { channel.active? }
