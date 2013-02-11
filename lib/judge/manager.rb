# ~*~ encoding: utf-8 ~*~
require 'judge/support/bunniable'

module Judge

  # Subscribes to the jobs queue (threads managed by bunny) and assigns jobs to
  # VMs.
  class Manager

    include Support::Bunniable

    def initialize
      @queue = channel.queue RABBIT_JOBS.queue[:name], RABBIT_JOBS.queue[:opts]
    end

    # Wait on jobs queue. Registers callback and returns immediately.
    def manage
      @queue.subscribe(&method(:on_job))
    end

    # Responds to an incoming job request.
    def on_job(info, meta, payload)
      Judge.logger.debug { '%s --[%s]--> manager' % [info.routing_key, meta[:message_id]] }
      callback(meta)
    end

    def callback(meta)
      exchange.publish 'done', # TODO
        routing_key: meta[:reply_to],
        timestamp: Time.now.to_i,
        correlation_id: meta[:message_id],
        app_id: 'judge v' + VERSION
      Judge.logger.debug { 'manager --[%s]--> %s' % [meta[:message_id], meta[:reply_to]] }
    end

  end

end
