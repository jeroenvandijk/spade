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

      request :post, "api/v1/gems" do |req|
        req.body = body
        req.add_field "Content-Length", body.size
        req.add_field "Content-Type",   "application/octet-stream"
        req.add_field "Authorization",  api_key
      end
    end

    def add_owner(package, email)
      request :post, "api/v1/gems/#{package}/owners" do |req|
        req.set_form_data 'email' => email
        req.add_field "Authorization",  api_key
      end
    end

    def remove_owner(package, email)
      request :delete, "api/v1/gems/#{package}/owners" do |req|
        req.set_form_data 'email' => email
        req.add_field "Authorization",  api_key
      end
    end

    def list(matcher, all)
      fetcher    = Gem::SpecFetcher.fetcher
      dependency = Gem::Dependency.new(matcher, Gem::Requirement.default)
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

    private

    def request(method, path)
      response = self.class.rubygems_api_request method, path do |req|
        yield req
      end
      response.body
    end
  end
end
