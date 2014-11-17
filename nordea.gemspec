# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'nordea/version'

Gem::Specification.new do |s|
  s.name        = 'nordea'
  s.version     = Nordea::VERSION
  s.authors     = ['Matias Korhonen', 'Alexander Simonov']
  s.email       = ['me@matiaskorhonen.fi', 'alex@simonov.me']
  s.homepage    = 'https://github.com/matiaskorhonen/nordea'
  s.summary     = 'Exchange rates from Nordea Bank'
  s.description = 'A Money.gem compatible currency exchange rate implementation for Nordea Bank'

  s.add_dependency 'money', '>= 6.0.0'
  s.add_dependency 'tzinfo', '>= 0.3.38'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 3.0.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'yard'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
end
