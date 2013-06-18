require 'em-ssh'
require 'active_support/core_ext/class/attribute'
require 'tangle/support/closeable_queue'
require 'tangle/tty_extension'

module Tangle

  class TTY

    class_attribute :terms
    self.terms = {}

    attr_reader :read, :write, :owner

    def initialize(user_id)
      @owner, @write = user_id, Support::CloseableQueue.new
      open_ssh
      TTY.terms[owner] ||= {}
      TTY.terms[owner][object_id] = self
    end

    # TODO multiple channels on the same connection?
    # FIXME error handling
    # FIXME remove hardcoded host and user
    # Creates a new SSH session and opens a channel on it.
    # @return [EM::CloseableQueue, EM::CloseableQueue, Fixnum] read, write, id
    def open_ssh(cols=nil, rows=nil)
      EM::Ssh.start 'beta.geniehub.org', 'codex' do |session|
        session.errback  { |err| Tangle.logger.error "#{err} (#{err.class})" }
        session.callback do |ssh|
          Tangle.logger.info '>> session started'
          channel = open_channel ssh, cols, rows
          channel.wait
          ssh.close
        end
      end
    end

    # Opens a channel on the given SSH session and requests for a pseudo tty
    # with a shell.
    # @return [EventMachine::Ssh::Connection::Channel] channel
    def open_channel(ssh, cols, rows)
      cols ||= Net::SSH::Connection::Channel::VALID_PTY_OPTIONS[:chars_wide]
      rows ||= Net::SSH::Connection::Channel::VALID_PTY_OPTIONS[:chars_high]
      channel = ssh.open_channel do |ch|
        Tangle.logger.info '>> channel opened'
        set_read_callbacks ch
        ch.request_pty(chars_wide: cols, chars_high: rows) do |pty, ok|
          raise SSHException, 'request_pty failed' unless ok
          pty.send_channel_request 'shell' do |_, success|
            raise SSHException, 'shell request failed' unless success
            Tangle.logger.info '>> shell opened'
            set_write_callbacks channel
          end
        end
      end
    end

    private

    # @return [void]
    def set_read_callbacks(ch)
      ch.on_data { |_, d| publish d }
      ch.on_extended_data { |_, d| publish d }
      ch.on_close { Tangle.logger.info '>> channel closed'; kill }
    end

    # @return [void]
    def set_write_callbacks(ch)
      @write.on_close { ch.close if ch.active? }
      @write.on_data  { |data| ch.send_data data }
    end

    # @return [Faye::Client] faye client
    def faye
      Tangle.faye.get_client
    end

    # Publishes the given data on the data channel
    # @return [void]
    def publish(data)
      faye.publish data_channel, id: object_id, data: data
    end

    # Tells user to kill terminal with given ID
    # @return [void]
    def kill
      faye.publish kill_channel, object_id
    end

    def kill_channel
      "/#{owner}/kill"
    end

    def data_channel
      "/#{owner}/data"
    end

  end

end
