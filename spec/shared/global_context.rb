# ~*~ encoding: utf-8 ~*~
require 'tangle'
require 'rspec/core/shared_context'
require 'factory_girl'

module Test

  module GlobalContext

    extend RSpec::Core::SharedContext

    FactoryGirl.find_definitions
    let(:output) { OUTPUT.flush; OUTPUT.string }
    let(:rand)   { Random.rand(100) }

  end

end
