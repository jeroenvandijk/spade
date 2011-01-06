module Spade
  class Remote
    extend Gem::GemcutterUtilities
    ENV["RUBYGEMS_HOST"] ||= "https://sproutcutter.heroku.com"

    def self.spade_dir(*path)
      File.join(ENV["HOME"], ".spade", *path)
    end

    def self.login(email, password)
      response = rubygems_api_request :get, "api/v1/api_key" do |request|
        request.basic_auth email, password
      end

      case response
      when Net::HTTPSuccess
        contents = YAML.dump(:spade_api_key => response.body)
        FileUtils.mkdir_p(spade_dir)
        File.open(spade_dir("credentials"), "w") do |file|
          file.write YAML.dump(:spade_api_key => response.body)
        end
        true
      else
        false
      end
    end

    def self.install(package)
      Gem.sources.replace [ENV["RUBYGEMS_HOST"]]
      Gem.use_paths(spade_dir)

      inst = Gem::DependencyInstaller.new {}
      inst.install package, Gem::Requirement.new([">= 0"])
      inst.installed_gems
    end
  end
end
