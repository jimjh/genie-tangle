# ~*~ encoding: utf-8 ~*~
shared_context 'remote rpc' do

  before(:suite) do
    @server = Tangle::Server.new
    @thread = @server.serve
  end

  let(:port) { @server.port }

  after(:suite) do
    @thread.kill
  end

end
