module Spade
  class Environment
    def self.spade_dir=(spade_dir)
      @spade_dir = spade_dir
    end

    def self.spade_dir(*path)
      File.join(@spade_dir, *path)
    end

    def initialize
      self.class.spade_dir = File.join(ENV["HOME"], SPADE_DIR)
      FileUtils.mkdir_p(spade_dir)

      ENV["RUBYGEMS_HOST"] ||= "https://sproutcutter.heroku.com"
      LibGems.sources.replace [ENV["RUBYGEMS_HOST"]]
      LibGems.use_paths(spade_dir)
      LibGems.source_index.refresh!

      spade_fetcher = LibGems::SpecFetcher.new
      def spade_fetcher.cache_dir(uri)
        Spade::Environment.spade_dir("#{uri.host}%#{uri.port}", File.dirname(uri.path))
      end

      # Do it again, since it got overridden
      LibGems.sources.replace [ENV["RUBYGEMS_HOST"]]

      LibGems::SpecFetcher.fetcher = spade_fetcher
    end

    def spade_dir(*path)
      self.class.spade_dir(*path)
    end
  end
end
