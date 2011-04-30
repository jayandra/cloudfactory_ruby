# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloud_factory/version"

Gem::Specification.new do |s|
  s.name        = "cloud_factory"
  s.version     = CloudFactory::VERSION
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
  
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "aruba"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "thor"
end
