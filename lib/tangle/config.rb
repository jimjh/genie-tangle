# ~*~ encoding: utf-8 ~*~
require 'logger'
require 'tangle/support/core_ext/deep_freeze'

module Tangle

  # == Server Options ==

  # Log file.
  LOG_FILE = STDOUT

  # Log level.
  LOG_LEVEL = ::Logger::INFO

  # Port number. Set to 0 for ephemeral port.
  PORT = 0

  # Host name. Set to '::1' for localhost.
  HOST = 'localhost'

end
