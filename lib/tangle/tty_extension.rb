require 'active_support/core_ext/hash/indifferent_access'

module Tangle

  class TTY

    # Faye Extension that handles TTY events.
    # @todo TODO on invalid input, send kill (or some error message)
    # @todo TODO security
    class Extension

      def incoming(message, callback)
        imessage = message.with_indifferent_access
        case imessage[:channel]
        when %r[\A/\d+/input\z] then handle_input  imessage
        when %r[\A/\d+/kill\z]  then handle_kill   imessage
        end
      ensure
        callback.call(message)
      end

      private

      # Finds appropriate terminal and forwards input to it.
      def handle_input(message)
        user    = extract_user message
        request = message[:data][:args]
        return unless (term = TTY[user, request.shift])
        term.write << request.join
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
