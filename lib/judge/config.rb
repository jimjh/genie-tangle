# ~*~ encoding: utf-8 ~*~
require 'logger'
require 'judge/version'
require 'judge/support/core_ext/deep_freeze'

module Judge

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
  HOST = '::1'

  # == Job Options ==

  # Maximum number of seconds for function.
  RUNJOB_TIMEOUT = 240

  # Maximum size for output file, in bytes.
  MAX_OUTPUT_FILE_SIZE = 1000 * 1024

  # == RabbitMq Options ==
  # Refer to http://rubybunny.info/articles/connecting.html for more details.
  # These are default values for the common options.
  BUNNY_OPTS = {
    # host: '127.0.0.1',
    # port: 5672,
    # ssl:  false,
    # user: 'guest',
    # pass: 'guest'
  }.deep_freeze

  # Configuration options related to the jobs queue.
  RABBIT_JOBS = OpenStruct.new \
    queue: {
      name: 'judge.jobs',       # name of jobs queue
      opts: { durable: true }   # options for jobs queue
    }.deep_freeze,
    message: {
      opts: {
        routing_key: 'judge.jobs',
        persistent:  true ,
        app_id:      'judge v' + VERSION
      }
    }.deep_freeze

end
