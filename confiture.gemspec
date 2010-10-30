# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "confiture/version"

Gem::Specification.new do |s|
  s.name        = "confiture"
  s.version     = Confiture::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["djtal"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "http://rubygems.org/gems/confiture"
  s.summary     = %q{use an html page like a ActiveRecord ressource}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "confiture"
  
  s.add_dependency "active_support"
  s.add_dependency "hpricot"
  s.add_dependency "open-uri"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
