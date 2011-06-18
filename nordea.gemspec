# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nordea/version"

Gem::Specification.new do |s|
  s.name        = "nordea"
  s.version     = Nordea::VERSION
  s.authors     = ["Matias Korhonen"]
  s.email       = ["matias@kiskolabs.com"]
  s.homepage    = "http://github.com/k33l0r/nordea"
  s.summary     = %q{Exchange rates from Nordea Bank}
  s.description = %q{A Money.gem compatible currency exchange rate implementation for Nordea Bank}

  s.rubyforge_project = "nordea"
  
  s.add_dependency "money", "~> 3.7.1"
  
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "simplecov"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
