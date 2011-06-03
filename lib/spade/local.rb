module Spade
  class Local < Repository
    def uninstall(package)
      LibGems::Uninstaller.new(package).uninstall
      true
    rescue LibGems::InstallError
      false
    end

    def pack(path)
      package = Spade::Package.new(creds.email)
      package.json_path = path
      if package.valid?
        silence do
          LibGems::Builder.new(package.to_spec).build
        end
      end
      package
    end

    def unpack(path, target)
      package       = Spade::Package.new
      package.spade = path
      unpack_dir    = File.expand_path(File.join(Dir.pwd, target, package.to_full_name))
      LibGems::Installer.new(path, :unpack => true).unpack unpack_dir
      package
    end

    def installed(packages)
      specs = LibGems.source_index.search dependency_for(packages)

      specs.map do |spec|
        [spec.name, spec.version, spec.original_platform]
      end
    end

    private

    def silence
      LibGems.configuration.verbose = false
      result = yield
      LibGems.configuration.verbose = true
      result
    end
  end
end
