module Spade
  class Remote
    def self.uri(*path)
      host = ENV["SPADE_URL"] || "https://sproutcutter.heroku.com"
      URI(File.join(host, *path))
    end

    def self.spade_dir(*path)
      File.join(ENV["HOME"], ".spade", *path)
    end

    def self.login(email, password)
      uri  = uri("/api/v1/api_key")
      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(email, password)
      response = http.request(request)

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
      require 'rubygems/commands/install_command'

      Gem.sources.replace [uri.to_s]
      Gem.use_paths(spade_dir)

      begin
        inst = Gem::DependencyInstaller.new {}
        inst.install package, Gem::Requirement.new([">= 0"])

        inst.installed_gems.each do |spec|
          puts "Successfully installed #{spec.full_name}"
        end
      rescue Gem::InstallError => e
        puts "Install error #{e}"
      rescue Gem::GemNotFoundException => e
        puts "Can't find package #{package}"
      end
    end
  end
end
