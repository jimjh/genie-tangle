require 'spec_helper'

describe Tangle::TTY do

  let(:collection) { Tangle::TTY }
  subject { collection }

  describe '.[]' do
    let(:tty) { OpenStruct.new owner: 6 }
    context 'given existing owner and terminal' do
      before(:each) { collection << tty }
      it 'returns the terminal' do
        collection[tty.owner, tty.object_id].should eq tty
      end
    end
    context 'given non-existing owner and terminal' do
      it 'returns the terminal' do
        collection[7, tty.object_id].should be_nil
      end
    end
  end

  #describe '.create' do
  #  before(:each) { Thread.new { EM.run {} } }
  #  let(:tty) { OpenStruct.new expired?: true }
  #  context 'given expired terminal' do
  #    it 'closes the terminal' do
  #      Tangle::SSH::Local.expects(:new).returns(tty)
  #      tty.stubs(:on_close).returns(true)
  #      tty.stubs(:open).returns(true)
  #      Tangle::TTY.create '0'
  #      Tangle::TTY.timer_added.should be_true
  #    end
  #  end
  #end

end

