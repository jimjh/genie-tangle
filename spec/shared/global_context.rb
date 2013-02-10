# ~*~ encoding: utf-8 ~*~
require 'rspec/core/shared_context'
require 'factory_girl'
module Test

  module GlobalContext

    FactoryGirl.find_definitions

    extend RSpec::Core::SharedContext
    let(:output) { OUTPUT.flush; OUTPUT.string }
    let(:rand)   { Random.rand(100) }

  end

end
