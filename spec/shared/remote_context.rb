# ~*~ encoding: utf-8 ~*~
shared_context 'remote rpc' do

  before(:each) do
    @server = Judge::Server.new
    @thread = @server.serve
  end

  let(:port) { @server.port }

  after(:each) do
    @thread.kill
  end

end
