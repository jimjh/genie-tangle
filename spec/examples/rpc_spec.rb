require 'spec_helper'

describe Tangle::Handler do

  subject { Tangle::Handler.new logger: Logger.new('/dev/null') }

  describe '#ping' do
    its(:ping) { should eq 'pong!' }
  end

  describe '#info' do

    its(:info) { should respond_to :uptime }
    its(:info) { should respond_to :threads }
    its(:info) { should respond_to :terminals }

    it 'reports the uptime' do
      subject.info.uptime.should >= 0
    end

    it 'reports the number of threads' do
      subject.info.threads.should have_key 'total'
      subject.info.threads.should have_key 'running'
    end

  end

end
