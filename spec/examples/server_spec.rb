require 'spec_helper'

describe Tangle do

  describe '::server' do

    it 'rescues from Interrupt' do
      Tangle::Server.any_instance.expects(:serve).raises(Interrupt)
      expect { Tangle.server }.to_not raise_exception
      output.should match(/Untangled\./)
    end

  end

end

describe Tangle::Server do

  describe '#initialize' do

    it 'sets the port number' do
      Tangle::Server.new('port' => rand).port.should be(rand)
    end

    it 'sets the port number to default value' do
      Tangle::Server.new.port.should be 5379
    end

  end

  describe '#serve' do

    let(:server) { Tangle::Server.new }

    context 'running server' do

      subject        { server }
      before(:each)  { server.serve }
      after(:each)   { server.thread.exit }

      its(:thread) { should be_alive }
      its(:thread) { should be_kind_of(Thread) }

      it 'logs the port number' do
        output.should match(/#{server.port}/)
      end

      its(:port) { should be(server.socket.handle.addr[1]) }

    end

  end

end
