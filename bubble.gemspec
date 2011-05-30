# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bubble/version"

Gem::Specification.new do |s|
  s.name        = "Bubble"
  s.version     = Bubble::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joseph HALTER"]
  s.email       = ["joseph@openhood.com"]
  s.homepage    = "https://github.com/JosephHalter/bubble"
  s.summary     = "Build scalable restful API"
  s.description = "Build scalable restful API with HATEOS and conditional requests."

  s.rubyforge_project = "bubble"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("rspec", ["~> 2.6.0"])
  s.add_development_dependency("rocco", ["~> 0.7"])
  s.add_development_dependency("sinatra", ["~> 1.3.0.d"])
  s.add_development_dependency("yajl-ruby", ["~> 0.8.2"])
end