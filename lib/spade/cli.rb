# ==========================================================================
# Project:   Spade - CommonJS Runtime
# Copyright: ©2010 Strobe Inc. All rights reserved.
# License:   Licened under MIT license (see LICENSE)
# ==========================================================================

require 'thor'
require 'spade/packager'
require 'spade/runtime'

module Spade
  module CLI
    class Base < Thor
      desc "package", "Manage packages"
      subcommand "package", Spade::Packager::CLI::Base

      desc "runtime", "Run Spade packages and applications"
      subcommand "runtime", Spade::Runtime::CLI::Base
    end
  end
end
