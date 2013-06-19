require './lib/tangle/version'

Gem::Specification.new do |gem|

  # NAME
  gem.name          = 'tangle'
  gem.version       = Tangle::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 2.0.0'

  # LICENSES
  gem.authors       = ['Jiunn Haur Lim']
  gem.email         = ['codex.is.poetry@gmail.com']
  gem.description   = %q{Untangles VM management and SSH connections}
  gem.summary       = %q{Untangles VM management and SSH connections}
  gem.homepage      = 'https://github.com/jimjh/genie-tangle'

  # PATHS
  gem.require_paths = %w[lib]
  gem.files         = %w[README.md] +
                      Dir.glob('lib/**/*') +
                      Dir.glob('bin/**/*')
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  # DEPENDENCIES
  gem.add_dependency 'thrift',        '~> 0.9'
  gem.add_dependency 'thor',          '~> 0.16'
  gem.add_dependency 'activesupport', '~> 3.2'
  gem.add_dependency 'pry',           '~> 0.9'
  gem.add_dependency 'faye',          '~> 0.8'
  gem.add_dependency 'thin',          '~> 1.5'
  gem.add_dependency 'em-ssh',        '~> 0.5.1'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rspec',        '~> 2.13'
  gem.add_development_dependency 'rake',         '~> 10.0'
  gem.add_development_dependency 'mocha',        '~> 0.10'
  gem.add_development_dependency 'factory_girl', '~> 4.2'
  gem.add_development_dependency 'faker',        '~> 1.1'

end
