# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spade/runtime/version'

Gem::Specification.new do |s|
  s.name        = "spade-runtime"
  s.version     = Spade::Runtime::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Jolley", "Peter Wagenet"]
  s.email       = ["charles@sproutcore.com", "peterw@strobecorp.com"]
  s.homepage    = "http://github.com/strobecorp/spade"
  s.summary = s.description = "Unified JavaScript runner for browser and command line"

  mswin = RbConfig::CONFIG["host_os"] =~ %r!(msdos|mswin|djgpp|mingw)!
  mri = !mswin && (!defined?(RUBY_ENGINE) || RUBY_ENGINE == "ruby")

  s.add_dependency "spade-core"
  s.add_dependency "spade-packager"
  s.add_dependency "spade-ruby" # Should we require this?

  # TODO: Do we need all of these?
  s.add_dependency "eventmachine", "~> 0.12.10"
  s.add_dependency "highline",     "~> 1.6.1"
  s.add_dependency "json_pure",    "~> 1.4.6"
  s.add_dependency "rack",         "~> 1.2.1"
  s.add_dependency "thor",         "~> 0.14.3"
  s.add_dependency "childlabor",   "~> 0.0.3"
  s.add_dependency "therubyracer", "~> 0.8.0" if mri

  s.add_development_dependency "rspec"

  #paths = `git submodule`.split("\n").map do |line|
  #  path = line.gsub(/^ \w+ ([^\s]+) .+$/,'\1')
  #  `cd #{path}; git ls-files`.split("\n").map { |p| File.join(path, p) }
  #end
  #paths << `git ls-files`.split("\n")
  #s.files      = paths.flatten
  #s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.files = Dir.glob("lib/**/*.rb")
  s.test_files = Dir.glob("spec/**/*.rb")

  s.executables        = ['spaderun']
  s.require_paths      = ["lib"]
end

