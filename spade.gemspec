# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spade/version'

Gem::Specification.new do |s|
  s.name        = "spade"
  s.version     = Spade::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Jolley", "Peter Wagenet"]
  s.email       = ["charles@sproutcore.com", "peterw@strobecorp.com"]
  s.homepage    = "http://github.com/strobecorp/spade"
  s.summary = s.description = "Unified JavaScript runner for browser and command line"

  s.required_rubygems_version = "~> 1.7.1"

  mswin = RbConfig::CONFIG["host_os"] =~ %r!(msdos|mswin|djgpp|mingw)!
  mri = !mswin && (!defined?(RUBY_ENGINE) || RUBY_ENGINE == "ruby")

  s.add_dependency "gemcutter",    "~> 0.6.1"
  s.add_dependency "eventmachine", "~> 0.12.10"
  s.add_dependency "highline",     "~> 1.6.1"
  s.add_dependency "json_pure",    "~> 1.4.6"
  s.add_dependency "rack",         "~> 1.2.1"
  s.add_dependency "thor",         "~> 0.14.3"
  s.add_dependency "childlabor",   "~> 0.0.3"
  s.add_dependency "therubyracer", "~> 0.8.0" if mri

  s.add_development_dependency "rspec"
  s.add_development_dependency "system_timer" if mri && RUBY_VERSION < "1.9"

  paths = `git submodule`.split("\n").map do |line|
    path = line.gsub(/^ \w+ ([^\s]+) .+$/,'\1')
    `cd #{path}; git ls-files`.split("\n").map { |p| File.join(path, p) }
  end
  paths << `git ls-files`.split("\n")
  s.files      = paths.flatten
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables        = ['spade']
  s.require_paths      = ["lib"]
end
