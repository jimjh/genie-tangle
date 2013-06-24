require 'thor'
require 'tangle'
require 'active_support/core_ext/hash/indifferent_access'

module Tangle

  # Exposes a command-line interface using Thor.
  class Cli < Thor

    class_option :'log-file',  type: :string,  default: nil
    class_option :'log-level', type: :numeric, default: LOG_LEVEL

    desc 'server', 'start a RPC server'
    option :port,        type: :numeric, default: PORT
    option :'faye-port', type: :numeric, default: FAYE_PORT
    def server
      ::Tangle.server options.with_indifferent_access
    end

    desc 'client COMMAND', 'use client to invoke remote RPC call'
    option :host, type: :string,  default: HOST
    option :port, type: :numeric, default: PORT
    def client(*args)
      ::Tangle.client args.shift, args, options.with_indifferent_access
    end

    def self.start(argv)
      super
    rescue Abort => e
      ::Tangle.logger.error e.message
      exit 1
    end

  end

end
