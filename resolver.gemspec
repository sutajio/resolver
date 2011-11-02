# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "resolver/version"

Gem::Specification.new do |s|
  s.name        = "resolver"
  s.version     = Resolver::VERSION
  s.authors     = ["Niklas Holmgren"]
  s.email       = ["niklas@sutajio.se"]
  s.homepage    = "http://github.com/sutajio/resolver/"
  s.summary     = %q{Resolver is a flexible Redis-backed high performance index and cache solution for ActiveModel-like objects.}
  s.description = %q{Resolver is a flexible Redis-backed high performance index and cache solution for ActiveModel-like objects.}

  s.rubyforge_project = "resolver"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.extra_rdoc_files  = [ "LICENSE", "README.md" ]
  s.rdoc_options      = ["--charset=UTF-8"]

  s.add_dependency('redis', '> 2.0.0')
  s.add_dependency('redis-namespace', '> 0.8.0')
  s.add_development_dependency('activemodel')
end
