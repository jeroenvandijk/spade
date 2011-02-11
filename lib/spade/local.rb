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
      package.json_path = path
      if package.valid?
        silence do
          Gem::Builder.new(package.to_spec).build
        end
      end
      package
    end

    def unpack(path, target)
      package       = Spade::Package.new
      package.spade = path
      unpack_dir    = File.expand_path(File.join(Dir.pwd, target, package.to_full_name))
      Gem::Installer.new(path, :unpack => true).unpack unpack_dir
      package
    end

    def installed
      dependency = Gem::Dependency.new(//, Gem::Requirement.default)
      specs = Gem.source_index.search dependency
      specs.map do |spec|
        [spec.name, spec.version, spec.original_platform]
      end
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
