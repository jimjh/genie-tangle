# ~*~ encoding: utf-8 ~*~
require 'em-ssh'
require 'socket'
require 'thread'
require 'pry'

# File.unlink 'xkcd.sock' if File.exists? 'xkcd.sock'
# module UNIXServerHandler
#   attr_accessor :channel
#   def receive_data(data)
#     channel.send_data data
#   end
# end

# FIXME
$counter = 0

def open_ssh
  r, w = EM::Queue.new, EM::Queue.new
  EM::Ssh.start 'beta.geniehub.org', 'codex' do |session|
    session.errback  { |err| $stderr.puts "#{err} (#{err.class})" }
    session.callback do |ssh|
      channel = ssh.open_channel do |ch|
        puts '>> channel opened.'
        ch.on_data { |_, d| r << d }
        ch.on_extended_data { |_, d| r << d }
        ch.on_close do
          puts '>> channel closed.'
          r << :EOF_SENTINEL
          w << :EOF_SENTINEL
        end
        ch.request_pty do |ch, success|
          ch = ch.send_channel_request 'shell' do |sh, success|
            puts '>> shell opened.'
            # EM::start_unix_domain_server('xkcd.sock', UNIXServerHandler)
            # do |h|
            #   h.channel = channel
            # end
            c = Proc.new do |data|
              if :EOF_SENTINEL == data
                channel.close
              else
                channel.send_data(data)
                w.pop(&c)
              end
            end
            w.pop(&c)
          end
        end
      end
      channel.wait
      ssh.close
    end
  end
  return r, w, ($counter += 1)
end
