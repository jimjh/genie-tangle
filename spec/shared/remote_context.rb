# ~*~ encoding: utf-8 ~*~
shared_context 'remote rpc' do

  before(:all) do
    @server = Judge::Server.new
    @thread = @server.serve
  end

  let(:port) { @server.port }

  after(:all) do
    @thread.kill
  end

end
