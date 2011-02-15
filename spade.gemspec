# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spade/version'

Gem::Specification.new do |s|
  s.name        = "spade"
  s.version     = Spade::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Jolley"]
  s.email       = ["charles@sproutcore.com"]
  s.homepage    = "http://github.com/sproutcore/spade"
  s.summary = s.description = "Unified JavaScript runner for browser and command line"

  s.required_rubygems_version = ">= 1.3.6"

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables        = ['spade']
  s.default_executable = "spade"
  s.require_paths      = ["lib"]
end
