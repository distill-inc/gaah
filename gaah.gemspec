# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gaah/version"

Gem::Specification.new do |s|
  s.name          = "gaah"
  s.version       = Gaah::VERSION
  s.date          = "2013-04-03"
  s.authors       = ["Hwan-Joon Choi"]
  s.email         = ["hc5duke@gmail.com"]
  s.homepage      = "https://github.com/distill-inc/gaah"

  s.summary       = "Limited API Wrapper for Google Apps API."
  s.description   = "Google Apps Marketplace API wrapper in ruby for Distill."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "nokogiri", "~> 1.5"
  s.add_dependency 'oauth', "~> 0.4"
  s.add_dependency 'queryparams', "0.0.3"
  s.add_development_dependency "rspec", "~> 2.5"
end
