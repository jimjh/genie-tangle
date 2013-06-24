module Tangle::SSH
  class Local < Base

    # TODO multiple channels on the same connection?
    # Creates a new SSH session and opens a channel on it. If any of the steps
    # fail, the session is closed and the tty is deleted.
    def open(opts={})
      EM::Ssh.start 'localhost', 'codex' do |session|
        session.errback  do |err|
          logger.error "#{err} (#{err.class})"
          close
        end
        session.callback do |ssh|
          logger.info '[tty] session started'
          channel = open_channel ssh, opts
          channel.wait
          ssh.close
          logger.info '[tty] session closed'
          close
        end
      end
    end

  end
end
