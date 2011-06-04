# ==========================================================================
# Project:   Spade - CommonJS Runtime
# Copyright: ©2010 Strobe Inc. All rights reserved.
# License:   Licened under MIT license (see LICENSE)
# ==========================================================================

require 'thor'
require 'spade/packager/cli/commands'
require 'spade/packager/cli/project_generator'
require 'spade/runtime/cli/commands'

module Spade
  module CLI
    class Base < Thor
      desc "package", "Manage packages"
      subcommand "package", Spade::Packager::CLI::Commands

      desc "runtime", "Run Spade packages and applications"
      subcommand "runtime", Spade::Runtime::CLI::Commands
    end
  end
end
