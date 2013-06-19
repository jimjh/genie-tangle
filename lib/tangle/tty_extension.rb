require 'active_support/core_ext/hash/indifferent_access'

module Tangle

  class TTY

    # Faye Extension that handles TTY events.
    # @todo TODO security
    class Extension

      def incoming(message, callback)
        message = message.with_indifferent_access
        case message[:channel]
        when %r[\A/\d+/input\z] then handle_input  message
        when %r[\A/\d+/kill\z]  then handle_kill   message
        end
      ensure
        callback.call(message)
      end

      private

      # Finds appropriate terminal and forwards input to it.
      def handle_input(message)
        user    = extract_user message
        id      = message[:data][:id]
        request = message[:data][:args]
        if (term = TTY[user, id])
          term.write << request.join
        else
          message[:error] = 'Terminal does not exist.'
        end
      end

      # Finds appropriate terminal and kills it.
      def handle_kill(message)
        Tangle.logger.info '[faye] kill received'
        user = extract_user message
        return unless (term = TTY[user, message[:data][:id]])
        term.write.close
      end

      # @return [String] user ID
      def extract_user(message)
        message[:channel].match(%r[\A/(\d+)/])[1]
      end

    end

  end

end
