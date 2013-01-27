# ~*~ encoding: utf-8 ~*~
require 'spec_helper'

describe Judge do

  describe '::server' do

    it 'rescues from Interrupt' do
      Judge::Server.any_instance.expects(:serve).raises(Interrupt)
      expect { Judge.server }.to_not raise_exception
      output.should match(/Court adjourned./)
    end

  end

end

describe Judge::Server do

  describe '#initialize' do

    it 'sets the port number' do
      Judge::Server.new('port' => rand).port.should be(rand)
    end

    it 'sets the port number to default value' do
      Judge::Server.new.port.should be_zero
    end

  end

  describe '#serve' do

    let(:server) { Judge::Server.new }

    context 'running server' do

      subject       { server }
      before(:all)  { server.serve }
      after(:all)   { server.thread.exit }

      its(:thread) { should be_alive }
      its(:thread) { should be_kind_of(Thread) }

      it 'logs the port number' do
        output.should match(/#{server.port}/)
      end

      its(:port) { should be(server.socket.handle.addr[1]) }

    end

  end

end
