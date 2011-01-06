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
      #Gem.configuration.verbose = 1

      command = Gem::Commands::InstallCommand.new
      command.options[:generate_ri] = false
      command.options[:generate_rdoc] = false
      command.options[:args] = package
      command.options[:domain] = :remote
      command.execute
    end
  end
end
