# ~*~ encoding: utf-8 ~*~
require 'shared/remote_context'
require 'securerandom'

describe Judge do

  include_context 'remote rpc'

  describe '::client' do

    it 'invokes the given command via the client' do
      Judge.client 'ping', nil, 'port' => port
      output.should match(/pong!/)
    end

  end

end

describe Judge::Client do

  include_context 'remote rpc'

  let(:rand_string) { SecureRandom.uuid }
  subject { Judge::Client.new 'port' => port }

  describe '#initialize' do

    it 'sets host, port' do
      c = Judge::Client.new('host' => rand_string, 'port' => rand)
      c.host.should eq rand_string
      c.port.should eq rand
    end

    it 'sets host to default value' do
      c = Judge::Client.new('port' => rand)
      c.host.should eq '::1'
    end

    it 'raises an exception if a port is not given' do
      expect { Judge::Client.new }.to raise_exception(ArgumentError)
    end

  end

  describe '#__invoke__' do

    it 'invokes the given block within an open transport' do
      subject.invoke { ping }.should eq 'pong!'
    end

  end

end
