require 'em-ssh'
require 'thread'
require 'active_support/core_ext/class/attribute'
require 'tangle/support/closeable_queue'
require 'tangle/tty_extension'

module Tangle

  # This class serves as a wrapper around Net-SSH's pseudo-tty and is designed
  # to be thread-safe. Since EM is asynchronous, during initialization the
  # success of the connection is unknown - on failure, the terminal is removed
  # from the +TTY.terms+ array, and a kill event is published.
  #
  # When data is received on stdout and stderr, a data event is published on
  # +/:owner/data+ with the format +{ id: tty_id, data: data }+.
  #
  # When the SSH connection is terminated, a kill event is published on
  # +/:owner/kill+ with the format +{ id: tty_id }+.
  # @todo TODO resize?
  class TTY

    class_attribute :terms, :mutex
    self.terms  = {} # XXX: state should be persisted
    self.mutex  = Mutex.new

    attr_reader :read, :write, :owner

    def initialize(user_id, opts={})
      @owner, @write = user_id, Support::CloseableQueue.new
      TTY << self
      open opts
    end

    # Retrieves terminals for given owner and tty id.
    def self.[](owner, id)
      mutex.synchronize do
        terms.has_key?(owner) ? terms[owner][id] : nil
      end
    end

    # Adds a new terminal to the list. Thread-safe.
    def self.<<(tty)
      mutex.synchronize do
        terms[tty.owner] ||= {}
        terms[tty.owner][tty.object_id] = tty
      end
    end

    # Removes a terminal from the list. Thread-safe.
    def self.delete(tty)
      mutex.synchronize do
        if terms.has_key? tty.owner
          terms[tty.owner].delete(tty.object_id)
          terms.delete(tty.owner) if terms[tty.owner].empty?
        end
      end
    end

    def self.count
      mutex.synchronize { terms.count }
    end

    private

    def close
      TTY.delete self
      kill
    end

    # TODO multiple channels on the same connection?
    # FIXME remove hardcoded host and user
    # Creates a new SSH session and opens a channel on it. If any of the steps
    # fail, the session is closed and the tty is deleted.
    def open(opts)
      EM::Ssh.start 'beta.geniehub.org', 'codex' do |session|
        session.errback  do |err|
          Tangle.logger.error "#{err} (#{err.class})"
          close
        end
        session.callback do |ssh|
          Tangle.logger.info '[tty] session started'
          channel = open_channel ssh, opts
          channel.wait
          ssh.close
          Tangle.logger.info '[tty] session closed'
          close
        end
      end
    end

    # Opens a channel on the given SSH session and requests for a pseudo tty
    # with a shell.
    # @return [EventMachine::Ssh::Connection::Channel] channel
    def open_channel(ssh, opts)
      channel = ssh.open_channel do |ch|
        Tangle.logger.info '[tty] channel opened'
        set_read_callbacks ch
        ch.request_pty(opts) do |pty, ok|
          open_shell(channel, pty) if ok
        end
      end
    end

    # Opens a shell on the given pty.
    # @return [void]
    def open_shell(channel, pty)
      pty.send_channel_request 'shell' do |_, success|
        if success
          Tangle.logger.info '[tty] shell opened'
          set_write_callbacks channel
        end
      end
    end

    # @return [void]
    def set_read_callbacks(ch)
      ch.on_data { |_, d| publish d }
      ch.on_extended_data { |_, d| publish d }
      ch.on_close { Tangle.logger.info '[tty] channel closed' }
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
      faye.publish kill_channel, id: object_id
    end

    def kill_channel
      "/#{owner}/kill"
    end

    def data_channel
      "/#{owner}/data"
    end

  end

end
