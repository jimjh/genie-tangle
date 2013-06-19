require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new 'spec'

desc 'Run tests'
task :default => :spec

Rake.application.instance_variable_get('@tasks').delete('release')

desc 'Prints error message and stops'
task :release do
  puts 'Are you sure you want to release this gem?'
end

namespace :thrift do
  desc 'Generates ruby scripts from tangle.thrift'
  task :generate do
    system './tangle.thrift'
  end
end
