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
  
  s.add_dependency "money", "~> 5.1.1"
  s.add_dependency "tzinfo", "~> 1.0.0"
  
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.14.1"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "webmock"
  s.add_development_dependency "yard"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
end
