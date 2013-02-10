# ~*~ encoding: utf-8 ~*~
require 'bunny'
require 'rspec/core/shared_context'

module Test
  module BunnyContext

    extend RSpec::Core::SharedContext

    let(:amq_queue)    { stub_everything('bunny queue') }
    let(:amq_exchange) { stub_everything('bunny exchange') }

    prepend_before :each do
      channel = stub_everything(queue: amq_queue, default_exchange: amq_exchange)
      conn    = stub_everything('bunny', start: true, create_channel: channel)
      Bunny.stubs(:new).returns(conn)
    end

  end
end
