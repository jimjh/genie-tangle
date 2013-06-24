require 'em-ssh'
require 'tangle/support/closeable_queue'

module Tangle
  module SSH

    # This class serves as a wrapper around Net-SSH's pseudo-tty.
    #
    # When data is received on stdout and stderr, a data event is published on
    # +/:owner/data+ with the format +{ id: tty_id, data: data }+.
    #
    # When the SSH connection is terminated, a kill event is published on
    # +/:owner/kill+ with the format +{ id: tty_id }+.
    # @todo TODO deal with resize?
    class Base

      attr_reader :owner, :write

      def initialize(owner: nil, faye_client: nil, logger: nil)
        @owner, @faye_client, @logger = owner, faye_client, logger
        @write = Support::CloseableQueue.new
        @listeners = []
      end

      def on_close(&block)
        @listeners << block
      end

      def close
        @listeners.map(&:call)
        kill
      end

      def open(opts={})
        raise NotImplementedError, 'SSH::Base is an abstract class'
      end

      private

      attr_reader :faye_client, :logger

      # Opens a channel on the given SSH session and requests for a pseudo tty
      # with a shell.
      # @return [EventMachine::Ssh::Connection::Channel] channel
      def open_channel(ssh, opts)
        channel = ssh.open_channel do |ch|
          logger.info '[tty] channel opened'
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
            logger.info '[tty] shell opened'
            set_write_callbacks channel
          end
        end
      end

      # @return [void]
      def set_read_callbacks(ch)
        ch.on_data { |_, d| publish d }
        ch.on_extended_data { |_, d| publish d }
        ch.on_close { logger.info '[tty] channel closed' }
      end

      # @return [void]
      def set_write_callbacks(ch)
        @write.on_close { ch.close if ch.active? }
        @write.on_data  { |data| ch.send_data data }
      end

      # Publishes the given data on the data channel
      # @return [void]
      def publish(data)
        faye_client.publish data_channel, id: object_id, data: data
      end

      # Tells user to kill terminal with given ID
      # @return [void]
      def kill
        faye_client.publish kill_channel, id: object_id
      end

      def kill_channel
        "/#{owner}/kill"
      end

      def data_channel
        "/#{owner}/data"
      end

    end
  end
end
