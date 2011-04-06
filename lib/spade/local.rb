module Spade
  class Local < Repository
    def uninstall(package)
      Gem::Uninstaller.new(package).uninstall
      true
    rescue Gem::InstallError
      false
    end

    def pack(path)
      package = Spade::Package.new(creds.email)
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

    def installed(packages)
      specs = Gem.source_index.search dependency_for(packages)

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
