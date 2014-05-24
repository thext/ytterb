# -*- encoding: utf-8 -*-

require File.expand_path('../lib/ytterb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "ytterb"
  gem.version       = Ytterb::VERSION
  gem.summary       = %q{ytterb finance data gen}
  gem.description   = %q{pulls financial data data via yahoo's YQL apis}
  gem.license       = "MIT"
  gem.authors       = ["thext"]
  gem.email         = "thext@outlook.com"
  gem.homepage      = "https://rubygems.org/gems/ytterb"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
