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
  s.homepage    = "http://github.com/strobecorp/spade"
  s.summary = s.description = "Unified JavaScript runner for browser and command line"

  s.required_rubygems_version = ">= 1.3.6"

  paths = `git submodule`.split("\n").map do |line|
    path = line.gsub(/^ \w+ ([^\s]+) .+$/,'\1')
    `cd #{path}; git ls-files`.split("\n").map { |p| File.join(path, p) }
  end
  paths << `git ls-files`.split("\n")
  puts paths.flatten
  s.files      = paths.flatten
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables        = ['spade']
  s.default_executable = "spade"
  s.require_paths      = ["lib"]
end
