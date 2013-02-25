# ~*~ encoding: utf-8 ~*~
require 'shared/remote_context'

describe Tangle::Client do

  include_context 'remote rpc'

  before :each do
    @client = Tangle::Client.new 'port' => port
    @client.transport.open
  end
  after(:each)  { @client.transport.close }
  subject       { @client }

  describe '#ping' do
    its(:ping) { should eq 'pong!' }
  end

  describe '#info' do

    its(:info) { should respond_to :uptime }
    its(:info) { should respond_to :threads }

    it 'reports the uptime' do
      subject.info.uptime.should > 0
    end

    it 'reports the number of threads' do
      subject.info.threads.should have_key 'total'
      subject.info.threads.should have_key 'running'
    end

  end

end
