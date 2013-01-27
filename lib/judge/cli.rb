# ~*~ encoding: utf-8 ~*~
require 'thor'
require 'judge'

module Judge

  # The judge-cli module exposes a command-line interface using Thor.
  class Cli < Thor

    desc 'server', 'start a RPC server on PORT'
    option :port, type: :numeric, default: Judge::Server::DEFAULT_PORT
    def server
      Judge.server options
    end

  end

end
