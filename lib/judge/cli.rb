# ~*~ encoding: utf-8 ~*~
require 'thor'
require 'judge'

module Judge

  # Exposes a command-line interface using Thor.
  class Cli < Thor

    desc 'server', 'start a RPC server'
    option :port, type: :numeric, default: Judge::Server::DEFAULT_PORT
    def server
      Judge.server options
    end

    desc 'client COMMAND', 'use client to invoke remote RPC call'
    option :host, type: :string,  default: Judge::Client::DEFAULT_HOST
    option :port, type: :numeric, required: true
    def client(*args)
      Judge.client args.shift, args, options
    end

  end

end
