require 'spec_helper'
require 'securerandom'

describe Tangle do

  describe '::client' do

    it 'invokes the given command via the client' do
      Thrift::BufferedTransport.any_instance.expects(:open)
      Thrift::BufferedTransport.any_instance.expects(:close)
      Tangle::Client.any_instance.expects(:ping).once.returns('pong')
      Tangle.client 'ping', nil, port: 0
    end

  end

end

describe Tangle::Client do

  let(:rand_string) { SecureRandom.uuid }
  subject { Tangle::Client.new port: port }

  describe '#initialize' do

    it 'sets host, port' do
      c = Tangle::Client.new(host: rand_string, port: rand)
      c.host.should eq rand_string
      c.port.should eq rand
    end

    it 'sets host to default value' do
      c = Tangle::Client.new(port: rand)
      c.host.should eq Tangle::HOST
    end

    it 'raises an exception if a port is not given' do
      expect { Tangle::Client.new }.to raise_exception(ArgumentError)
    end

  end

end
