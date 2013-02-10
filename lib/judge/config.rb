# ~*~ encoding: utf-8 ~*~
module Judge

  # All of the configuration options below can be overridden from the
  # command-line.

  # Log file.
  LOG_FILE = STDOUT

  # Log level.
  LOG_LEVEL = Logger::INFO

  # Port number. Set to 0 for ephemeral port.
  PORT = 0

  # Host name. Set to '::1' for localhost.
  HOST = '::1'

  # Maximum number of seconds for function.
  RUNJOB_TIMEOUT = 240

  # Maximum size for output file, in bytes.
  MAX_OUTPUT_FILE_SIZE = 1000 * 1024

end
