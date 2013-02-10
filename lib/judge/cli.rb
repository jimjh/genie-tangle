# ~*~ encoding: utf-8 ~*~
require 'thor'
require 'judge'

module Judge

  # Exposes a command-line interface using Thor.
  class Cli < Thor

    class_option :'log-file',  type: :string,  default: nil
    class_option :'log-level', type: :numeric, default: LOG_LEVEL

    desc 'server', 'start a RPC server'
    option :port, type: :numeric, default: PORT
    def server
      ::Judge.server options
    end

    desc 'client COMMAND', 'use client to invoke remote RPC call'
    option :host, type: :string,  default: HOST
    option :port, type: :numeric, required: true
    def client(*args)
      ::Judge.client args.shift, args, options
    end

    def self.start(argv)
      super
    rescue Abort => e
      ::Judge.logger.error e.message
      exit 1
    end

  end

end
