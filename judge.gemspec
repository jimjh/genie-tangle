# ~*~ encoding: utf-8 ~*~
require './lib/judge/version'

Gem::Specification.new do |gem|

  # NAME
  gem.name          = 'judge'
  gem.version       = Judge::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9.2'

  # LICENSES
  gem.authors       = ['Jiunn Haur Lim']
  gem.email         = ['codex.is.poetry@gmail.com']
  gem.description   = %q{Judges submissions.}
  gem.summary       = %q{Judges submissions.}
  gem.homepage      = 'https://github.com/jimjh/genie-judge'

  # PATHS
  gem.require_paths = %w[lib]
  gem.files         = %w[LICENSE README.md] +
                      Dir.glob('lib/**/*') +
                      Dir.glob('bin/**/*')
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  # DEPENDENCIES
  gem.add_dependency 'thrift',        '~> 0.9.0'
  gem.add_dependency 'thor',          '~> 0.16.0'
  gem.add_dependency 'activesupport', '~> 3.2.9'
  gem.add_dependency 'pry'

  gem.add_development_dependency 'yard',         '~> 0.8.3'
  gem.add_development_dependency 'debugger-pry', '~> 0.1.1'
  gem.add_development_dependency 'rspec',        '~> 2.12.0'
  gem.add_development_dependency 'rake',         '~> 10.0.0'
  gem.add_development_dependency 'mocha',        '~> 0.10.5'

end
