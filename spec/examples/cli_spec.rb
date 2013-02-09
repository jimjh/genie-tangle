# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'judge/cli'

describe Judge::Cli do

  subject { Judge::Cli }

  context 'thor task' do
    subject { Judge::Cli.all_tasks['server'] }
    it { should_not be_nil }
    its(:options) { should have_key(:port) }
    its(:options) { should satisfy { |o| o[:port].type == :numeric } }
  end

  describe '::server' do

    it 'invokes Judge::server' do
      Judge.expects(:server).with(has_entry('port', 1234)).returns(nil)
      Judge::Cli.start(%w[server --port 1234])
    end

  end

end
