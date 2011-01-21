module Spade::CLI
  class Owner < Thor
    desc "owner add", "Allow another user to push new versions of your spade package"
    def add(package, email)
      remote = Spade::Remote.new
      if remote.api_key
        say remote.add_owner(package, email)
      else
        say "Please login first with `spade login`."
      end
    end
  end
end
