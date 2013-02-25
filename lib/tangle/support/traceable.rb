# ~*~ encoding: utf-8 ~*~
module Tangle
  module Support
    module Traceable

      # @return [String] timestamped trace message
      def trace(message)
        '%s | %s: %s' % [Time.now, caller[0][/`([^']*)'/, 1], message]
      end

    end
  end
end
