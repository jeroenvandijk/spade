module Spade::CLI
  class Owner < Thor
    default_task :list

    desc "owner list [PACKAGE]", "Display owners of a package"
    def list(package)
      remote = Spade::Remote.new
      if remote.api_key
        yaml   = remote.list_owners(package)
        owners = YAML.load(yaml)

        if owners.is_a?(Array)
          say "Owners for package: #{package}"
          owners.each do |owner|
            say "- #{owner['email']}"
          end
        else
          say owners
        end
      else
        say "Please login first with `spade login`."
      end
    end

    desc "owner add [PACKAGE] [EMAIL]", "Allow another user to push new versions of your spade package"
    def add(package, email)
      remote = Spade::Remote.new
      if remote.api_key
        say remote.add_owner(package, email)
      else
        say "Please login first with `spade login`."
      end
    end

    desc "owner remove [PACKAGE] [EMAIL]", "Allow another user to push new versions of your spade package"
    def remove(package, email)
      remote = Spade::Remote.new
      if remote.api_key
        say remote.remove_owner(package, email)
      else
        say "Please login first with `spade login`."
      end
    end
  end
end