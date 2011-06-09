require 'libgems/config_file'

module LibGems
  class ConfigFile
    def credentials_path
      File.join(LibGems.user_home, ".spade", "credentials")
    end
  end
end
