module Spade
  class Local
    def initialize
      @env   = Environment.new
      @creds = Credentials.new(@env)
    end

    def logged_in?
      !@creds.api_key.nil?
    end

    def uninstall(package)
      index = Gem::SourceIndex.from_gems_in(@env.spade_dir("specifications"))
      index.refresh!
      specs = index.find_name package

      if specs.first
        uninstaller = Gem::Uninstaller.new(package, :ignore => true)
        uninstaller.uninstall_gem(specs.first, specs)
        true
      else
        false
      end
    end

    def pack(path)
      package = Spade::Package.new(@creds.email)
      if File.exist?(path)
        package.json = path
        silence do
          Gem::Builder.new(package.to_spec).build
        end
        package
      else
        false
      end
    end

    def unpack(path)
      package       = Spade::Package.new
      package.spade = path
      unpack_dir    = File.expand_path(File.join(Dir.pwd, package.to_s))
      Gem::Installer.new(path, :unpack => true).unpack unpack_dir
      package
    end

    private

    def silence
      Gem.configuration.verbose = false
      result = yield
      Gem.configuration.verbose = true
      result
    end
  end
end
