module Spade
  class Remote
    extend Gem::GemcutterUtilities
    ENV["RUBYGEMS_HOST"] ||= "https://sproutcutter.heroku.com"

    def self.spade_dir(*path)
      base = File.join(ENV["HOME"], ".spade")
      FileUtils.mkdir_p(base)
      File.join(base, *path)
    end

    def self.login(email, password)
      response = rubygems_api_request :get, "api/v1/api_key" do |request|
        request.basic_auth email, password
      end

      case response
      when Net::HTTPSuccess
        self.api_key = response.body
        true
      else
        false
      end
    end

    def self.push(package)
      begin
        body = Gem.read_binary package
        Gem::Format.from_file_by_path(package)
      rescue Exception => ex
        return "There was a problem opening your package.\n#{ex.class}: #{ex.to_s}"
      end

      response = rubygems_api_request :post, "api/v1/gems" do |request|
        request.body = body
        request.add_field "Content-Length", body.size
        request.add_field "Content-Type",   "application/octet-stream"
        request.add_field "Authorization",  api_key
      end

      response.body
    end

    def self.api_key=(api_key)
      File.open(spade_dir("credentials"), "w") do |file|
        file.write YAML.dump(:spade_api_key => api_key)
      end
    end

    def self.api_key
      credentials = spade_dir("credentials")
      if File.exists?(credentials)
        YAML.load_file(credentials)[:spade_api_key]
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
