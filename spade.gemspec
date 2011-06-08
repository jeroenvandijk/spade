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

  s.add_dependency 'spade-packager'
  s.add_dependency 'spade-runtime'

  s.add_development_dependency 'rspec'

=begin
  paths = `git submodule`.split("\n").map do |line|
    path = line.gsub(/^ \w+ ([^\s]+) .+$/,'\1')
    `cd #{path}; git ls-files`.split("\n").map { |p| File.join(path, p) }
  end
  paths << `git ls-files`.split("\n")
  s.files      = paths.flatten
=end
  paths = Dir.glob("{bin,examples,lib,spec,vendor}/**/*")
  paths += %w(Buildfile Gemfile package.json Rakefile README.md)
  s.files = paths
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.executables        = ['spade']
  s.require_paths      = ["lib"]
end
