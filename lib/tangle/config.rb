require 'logger'

module Tangle

  # == Server Options ==

  # Log file.
  LOG_FILE = STDOUT

  # Log level.
  LOG_LEVEL = ::Logger::INFO

  # Port number. Set to 0 for ephemeral port.
  PORT = 5379

  # Host name. Set to '::1' for localhost.
  HOST = 'localhost'

  # Faye Port
  FAYE_PORT = 3300

end
