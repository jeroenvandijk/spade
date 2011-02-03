module Spade
  class Local
    def initialize
      @env = Environment.new
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
      package = Spade::Package.new(path, "user@example.com")
      spec    = package.to_spec
      silence do
        Gem::Builder.new(spec).build
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
