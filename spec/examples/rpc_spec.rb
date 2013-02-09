# ~*~ encoding: utf-8 ~*~
require 'shared/remote_context'

describe Judge::Client do

  include_context 'remote rpc'
  subject { Judge::Client.new 'port' => port }

  before(:all) { subject.transport.open }
  after(:all)  { subject.transport.close }

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
