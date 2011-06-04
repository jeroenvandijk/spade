require 'spade/packager/environment'
require 'spade/packager/credentials'

module Spade::Packager
  class Repository
    attr_accessor :env, :creds

    def initialize
      self.env   = Environment.new
      self.creds = Credentials.new(@env)
    end

    def logged_in?
      !self.creds.api_key.nil?
    end

    def dependency_for(packages)
      LibGems::Dependency.new(/(#{packages.join('|')})/, LibGems::Requirement.default)
    end
  end
end

