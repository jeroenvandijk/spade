module Spade
  class Remote
    extend Gem::GemcutterUtilities

    def initialize
      ENV["RUBYGEMS_HOST"] ||= "https://sproutcutter.heroku.com"
      Gem.sources.replace [ENV["RUBYGEMS_HOST"]]
      Gem.use_paths(spade_dir)
    end

    def login(email, password)
      response = self.class.rubygems_api_request :get, "api/v1/api_key" do |request|
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

    def push(package)
      begin
        body = Gem.read_binary package
        Gem::Format.from_file_by_path(package)
      rescue Exception => ex
        return "There was a problem opening your package.\n#{ex.class}: #{ex.to_s}"
      end

      response = self.class.rubygems_api_request :post, "api/v1/gems" do |request|
        request.body = body
        request.add_field "Content-Length", body.size
        request.add_field "Content-Type",   "application/octet-stream"
        request.add_field "Authorization",  api_key
      end

      response.body
    end


    def list(all)
      fetcher    = Gem::SpecFetcher.fetcher
      dependency = Gem::Dependency.new(//, Gem::Requirement.default)
      fetcher.find_matching(dependency, all, false, false).map(&:first)
    end

    def install(package, options)
      inst = Gem::DependencyInstaller.new {}
      inst.install package, Gem::Requirement.new([options])
      inst.installed_gems
    end

    def spade_dir(*path)
      base = File.join(ENV["HOME"], SPADE_DIR)
      FileUtils.mkdir_p(base)
      File.join(base, *path)
    end

    def api_key=(api_key)
      File.open(spade_dir("credentials"), "w") do |file|
        file.write YAML.dump(:spade_api_key => api_key)
      end
    end

    def api_key
      credentials = spade_dir("credentials")
      if File.exists?(credentials)
        YAML.load_file(credentials)[:spade_api_key]
      else
        false
      end
    end
  end
end
