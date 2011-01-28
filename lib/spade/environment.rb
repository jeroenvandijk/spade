module Spade
  class Environment
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
  end
end
