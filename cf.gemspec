# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cf/version"

Gem::Specification.new do |s|
  s.name        = "cloud_factory"
  s.version     = CF::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Millisami"]
  s.email       = ["millisami@gmail.com"]
  s.homepage    = "http://cloudfactory.com"
  s.summary     = %q{Cloudfactory}
  s.description = %q{Cloudfactory}

  s.rubyforge_project = "cloud_factory"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["cf"]
  s.require_paths = ["lib"]
  
  s.add_dependency  "i18n"
  s.add_dependency  "activesupport", '~> 3.0.0'
  s.add_dependency  "hashie", "~> 1.0.0"
  s.add_dependency  "httparty", "~> 0.7.7"
  s.add_dependency  "rest-client"
  s.add_dependency  "json"
  
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "aruba"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "thor"
  s.add_development_dependency "rdoc", "~> 3.5.3"
  s.add_development_dependency "vcr"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "ruby-debug19"
end
