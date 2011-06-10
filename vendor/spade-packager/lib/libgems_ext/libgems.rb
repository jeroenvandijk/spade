require 'libgems'

module LibGems
  def self.default_sources
    %w[https://sproutcutter.heroku.com/]
  end

  def self.default_dir
    File.join(ENV["HOME"], Spade::SPADE_DIR)
  end

  def self.config_file
    File.join LibGems.user_home, '.spaderc'
  end

  def self.dir
    @gem_home ||= nil
    set_home(ENV['SPADE_HOME'] || LibGems.configuration.home || default_dir) unless @gem_home
    @gem_home
  end
end
