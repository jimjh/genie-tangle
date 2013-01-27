# ~*~ encoding: utf-8 ~*~
require 'rspec/core/shared_context'
module Test

  module GlobalContext

    extend RSpec::Core::SharedContext
    let(:output) { OUTPUT.flush; OUTPUT.string }

  end

end
