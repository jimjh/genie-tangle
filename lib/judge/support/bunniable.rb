# ~*~ encoding: utf-8 ~*~
module Judge
  module Support
    module Bunniable

      # @see http://www.rabbitmq.com/tutorials/amqp-concepts.html
      def channel
        # don't share channels across threads
        Thread.current[self.class.to_s + '_channel'] ||= Judge.bunny.create_channel
      end

      # @see http://www.rabbitmq.com/tutorials/amqp-concepts.html
      def exchange
        Thread.current[self.class.to_s + '_exchange'] ||= channel.default_exchange
      end

    end

  end
end
