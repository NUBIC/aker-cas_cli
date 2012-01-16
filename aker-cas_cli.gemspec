# -*- encoding: utf-8 -*-
require File.expand_path('../lib/aker/cas_cli/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rhett Sutphin"]
  gem.email         = ["rhett@detailedbalance.net"]
  gem.summary       = %q{Provides an Aker-compatible way to acquire CAS proxy tickets in a non-interactive context.}
  gem.description   = gem.summary + " See README.md for more information."
  gem.homepage      = "https://github.com/NUBIC/aker-cas_cli"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "aker-cas_cli"
  gem.require_paths = ["lib"]
  gem.version       = Aker::CasCli::VERSION

  gem.add_dependency 'aker', '~> 3.0'
  gem.add_dependency 'mechanize', '~> 2.1.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'rubycas-server', '~> 1.0'
  gem.add_development_dependency 'childprocess', '~> 0.2.9'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'thin'
end
