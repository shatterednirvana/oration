# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oration/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "oration"
  gem.version       = Oration::VERSION
  gem.authors       = ["Chris Bunch", "Andres Riofrio"]
  gem.email         = "appscale_community@googlegroups.com"
  gem.homepage      = "http://appscale.cs.ucsb.edu"
  gem.summary       = "Generates Cicero-ready Google App Engine apps from regular code"
  gem.description   = %{
    Oration converts a function written in Python or Go into a Google App Engine
    application that conforms to the Cicero API, allowing the given function to
    be automatically executed over Google App Engine or AppScale in an
    embarrassingly parallel fashion.
  }

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency "mixlib-cli"
  gem.add_dependency "mustache"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rdoc"
  gem.add_development_dependency "json"
  gem.add_development_dependency "rest-client"
  gem.add_development_dependency "require_all"
end
