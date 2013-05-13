# ~*~ encoding: utf-8 ~*~
require 'spec_helper'
require 'timeout'
require 'tangle/support/closeable_queue'

describe Tangle::Support::CloseableQueue do

  around :each do |example|
    Timeout.timeout(2) { example.run }
  end

  it 'invokes on_close callbacks' do
    EM.run do
      queue = Tangle::Support::CloseableQueue.new
      queue.on_close { EM.stop }
      queue.on_data  {}
      queue.close
    end
  end

  it 'invokes on_data callbacks' do
    counter = 0
    EM.run do
      queue = Tangle::Support::CloseableQueue.new
      queue.on_close { EM.stop }
      queue.on_data { |i| counter += i }
      5.times { |i| queue << i }
      queue.close
    end
    counter.should be 10
  end

end

