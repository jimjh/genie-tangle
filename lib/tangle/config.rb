# ~*~ encoding: utf-8 ~*~
require 'logger'
require 'tangle/support/core_ext/deep_freeze'

module Tangle

  # All of the configuration options below can be overridden from the
  # command-line.

  # == Server Options ==

  # Log file.
  LOG_FILE = STDOUT

  # Log level.
  LOG_LEVEL = ::Logger::INFO

  # Port number. Set to 0 for ephemeral port.
  PORT = 0

  # Host name. Set to '::1' for localhost.
  HOST = 'localhost'

  # == Job Options ==

  # Maximum number of seconds for function.
  RUNJOB_TIMEOUT = 240

  # Maximum size for output file, in bytes.
  MAX_OUTPUT_FILE_SIZE = 1000 * 1024

end
