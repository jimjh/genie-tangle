# ~*~ encoding: utf-8 ~*~
module Tangle

  class TTY

    # Faye Extension that handles TTY events.
    # @todo TODO security
    # @todo TODO handle disconnect
    class Extension

      def incoming(message, callback)
        case message['channel']
        when %r[\A/\d+/input\z] then handle_input  message
        when %r[\A/\d+/kill\z]  then handle_kill   message
        end
      ensure
        callback.call(message)
      end

      private

      # Finds appropriate terminal and forwards input to it.
      def handle_input(message)
        user  = extract_user message
        return unless (terms = TTY.terms[user])
        request = message['data']['args']
        return unless (term = terms[request.shift])
        term.write << request.join
      end

      # Finds appropriate terminal and kills it.
      def handle_kill(message)
        user = extract_user message
        return unless (terms = TTY.terms[user])
        return unless (term = terms.delete(message['data']))
        term.write.close
        TTY.terms.delete(user) if terms.empty?
      end

      # @return [String] user ID
      def extract_user(message)
        message['channel'].match(%r[\A/(\d+)/])[1]
      end

    end

  end

end
