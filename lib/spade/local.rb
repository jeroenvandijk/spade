module Spade
  class Local
    def initialize
      @env = Environment.new
    end

    def uninstall(package)
      index = Gem::SourceIndex.from_gems_in(@env.spade_dir("specifications"))
      index.refresh!
      specs = index.find_name package
      uninstaller = Gem::Uninstaller.new(package, {})
      uninstaller.uninstall_gem(specs.first, specs)
    end
  end
end
