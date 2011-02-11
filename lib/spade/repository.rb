module Spade
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
      Gem::Dependency.new(/(#{packages.join('|')})/, Gem::Requirement.default)
    end
  end
end
