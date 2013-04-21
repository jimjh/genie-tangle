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
# EM::start_unix_domain_server('xkcd.sock', UNIXServerHandler)
# do |h|
#   h.channel = channel
# end

# FIXME
$counter = 0

class EM::CloseableQueue < EM::Queue

  def close
    self << :EOF_SENTINEL
  end

  def on_close(*a, &b)
    @close_cb = EM::Callback(*a, &b)
  end

  def on_data(*a, &b)
    cb    = EM::Callback(*a, &b)
    proxy = Proc.new do |ele|
      if :EOF_SENTINEL == ele
        EM.schedule @close_cb if @close_cb
      else
        cb.call ele
        pop(&proxy) # loop
      end
    end
    pop(&proxy)
  end

end

# @return [EM::CloseableQueue, EM::CloseableQueue, Fixnum] read, write, id
def open_ssh(cols, rows)
  r, w = EM::CloseableQueue.new, EM::CloseableQueue.new
  EM::Ssh.start 'beta.geniehub.org', 'codex' do |session|
    session.errback  { |err| $stderr.puts "#{err} (#{err.class})" }
    session.callback do |ssh|
      channel = ssh.open_channel do |ch|
        puts '>> channel opened.'
        ch.on_data { |_, d| r << d }
        ch.on_extended_data { |_, d| r << d }
        ch.on_close do
          puts '>> channel closed.'
          r.close
        end
        cols ||= Net::SSH::Connection::Channel::VALID_PTY_OPTIONS[:chars_wide]
        rows ||= Net::SSH::Connection::Channel::VALID_PTY_OPTIONS[:chars_high]
        ch.request_pty(chars_wide: cols, chars_high: rows) do |ch, success|
          ch = ch.send_channel_request 'shell' do |sh, success|
            puts '>> shell opened.'
            w.on_close { channel.close unless !channel.active? }
            w.on_data  { |data| channel.send_data data }
          end
        end
      end
      channel.wait
      ssh.close
    end
  end
  return r, w, ($counter += 1)
end
