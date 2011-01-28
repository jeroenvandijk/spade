module Spade
  class Remote
    extend Gem::GemcutterUtilities

    def initialize
      @env = Environment.new
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

    def list_owners(package)
      request :get, "api/v1/gems/#{package}/owners.yaml" do |req|
        req.add_field "Authorization",  api_key
      end
    end

    def list_packages(matcher, all, prerelease)
      fetcher    = Gem::SpecFetcher.fetcher
      dependency = Gem::Dependency.new(matcher, Gem::Requirement.default)
      fetcher.find_matching(dependency, all, false, prerelease).map(&:first)
    end

    def install(package, version, prerelease)
      inst = Gem::DependencyInstaller.new(:prerelease => prerelease)
      inst.install package, Gem::Requirement.new([version])
      inst.installed_gems
    end

    def api_key=(api_key)
      File.open(@env.spade_dir("credentials"), "w") do |file|
        file.write YAML.dump(:spade_api_key => api_key)
      end
    end

    def api_key
      credentials = @env.spade_dir("credentials")
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
