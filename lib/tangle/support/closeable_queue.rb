require 'eventmachine'

module Tangle
  module Support

    # A thread-safe {EM::Queue} that allows #on_close and #on_data callbacks.
    class CloseableQueue < EM::Queue

      # Closes the queue. Callbacks registered with +on_data+ will be stopped,
      # and callbacks registered with +on_close+ will be invoked.
      def close
        self << :EOF_SENTINEL
      end

      # Registers a callback that is invoked on close. Requires #on_data to
      # work.
      # @see EM::Callback
      def on_close(*a, &b)
        @close_cb = EM::Callback(*a, &b)
      end

      # Registers a callback that is invoked whenever data is received. If this
      # is called more than once, the behavior is undefined.
      # @see EM::Callback
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

  end
end
