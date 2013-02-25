# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'tangle/cli'

describe Tangle::Cli do

  subject { Tangle::Cli }

  context 'thor task' do
    subject { Tangle::Cli.all_tasks['server'] }
    it { should_not be_nil }
    its(:options) { should have_key(:port) }
    its(:options) { should satisfy { |o| o[:port].type == :numeric } }
  end

  describe '::server' do

    it 'invokes Tangle::server' do
      Tangle.expects(:server).with(has_entry('port', 1234)).returns(nil)
      Tangle::Cli.start(%w[server --port 1234])
    end

  end

end
