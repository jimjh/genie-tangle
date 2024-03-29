require 'thread'
require 'active_support/core_ext/class/attribute'
require 'tangle/ssh'

module Tangle

  # This class is designed to be thread-safe tty factory. During
  # initialization, the success of the connection is unknown; however, on
  # failure, the dead terminal is removed from the +TTY.terms+ array.
  class TTY

    EXPIRY_TIMER = 15*60 # check every 15 minutes

    class_attribute :terms, :mutex, :timer_added
    self.terms  = {} # XXX: state should be persisted
    self.mutex  = Mutex.new
    self.timer_added = false

    private_class_method :new

    # @return [SSH::Base] tty
    def self.create(user_id, opts={})
      add_timer unless timer_added
      cls = (ENV['RACK_ENV'] == 'production') ? SSH::Remote : SSH::Local
      tty = cls.new owner: user_id, faye_client: faye_client, logger: logger
      TTY << tty
      tty.on_close { TTY.delete tty }
      tty.open opts
      tty
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

    def self.faye_client
      Tangle.faye.get_client
    end
    private_class_method :faye_client

    def self.logger
      Tangle.logger
    end

    def self.each
      terms.each do |_, ttys|
        ttys.each { |_, tty| yield tty }
      end
    end

    def self.add_timer
      EM.add_periodic_timer(EXPIRY_TIMER) do
        self.each do |tty|
          if tty.expired?
            logger.info "[tty] tty for #{tty.owner} expired"
            tty.close
          end
        end
      end
      self.timer_added = true
    end

  end
end
