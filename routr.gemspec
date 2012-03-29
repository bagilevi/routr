# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "routr/version"

Gem::Specification.new do |s|
  s.name        = "routr"
  s.version     = Routr::VERSION
  s.authors     = ["Levente Bagi"]
  s.email       = ["levente@picklive.com"]
  s.homepage    = ""
  s.summary     = %q{Finds the shortest path in a graph, allowing unusual cost definitions}
  s.description = %q{Implements Dijkstra's algorithm to find the shortest path in a graph. The cost of an edge can be more general than just a numeric value.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
