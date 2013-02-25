# ~*~ encoding: utf-8 ~*~
require 'rubygems'
require 'bundler/setup'
require 'tmpdir'
require 'rspec'

begin Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

module Test
  ROOT   = Pathname.new File.dirname(__FILE__)
  OUTPUT = StringIO.new
end

$:.unshift Test::ROOT + '..' + 'lib'
require 'shared/global_context'

RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.mock_framework = :mocha
  config.include Test::GlobalContext

  config.before(:suite) { Tangle.reset_logger 'log-file' => Test::OUTPUT }
  config.before(:each)  { Tangle.stubs(:reset_logger) }
  config.after(:each)   { Test::OUTPUT.truncate 0 }

end

