module Spade
  class Local
    def initialize
      ENV["RUBYGEMS_HOST"] ||= "https://sproutcutter.heroku.com"
      Gem.sources.replace [ENV["RUBYGEMS_HOST"]]
      Gem.use_paths(spade_dir)
    end

    def spade_dir(*path)
      base = File.join(ENV["HOME"], SPADE_DIR)
      FileUtils.mkdir_p(base)
      File.join(base, *path)
    end

    def uninstall(package)
      index = Gem::SourceIndex.from_gems_in(spade_dir("specifications"))
      index.refresh!
      specs = index.find_name package
      uninstaller = Gem::Uninstaller.new(package, {})
      uninstaller.uninstall_gem(specs.first, specs)
    end
  end
end
