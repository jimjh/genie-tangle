# ~*~ encoding: utf-8 ~*~
require 'thrift'
require 'pathname'

# Import the generated ruby code.
gen = Pathname.new(__FILE__).dirname + '..' + 'gen'
$:.push gen
require gen + 'judge'

require 'judge/server'

module Judge

  # Starts a RPC server.
  def self.server(opts={})
    server = Server.new opts
    server.serve
  end

end
