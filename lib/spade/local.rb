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
  end
end
