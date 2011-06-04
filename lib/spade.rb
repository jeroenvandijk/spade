# ==========================================================================
# Project:   Spade - CommonJS Runtime
# Copyright: ©2010 Strobe Inc. All rights reserved.
# License:   Licened under MIT license (see LICENSE)
# ==========================================================================

require 'libgems'
require 'libgems/user_interaction'
require 'libgems/uninstaller'
require 'libgems/dependency_installer'
require 'libgems/gemcutter_utilities'
require 'libgems/validator'
require 'rubygems_plugin' # Gemcutter

require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'
require 'yaml'

require 'eventmachine'
require 'highline'
require 'thor'
require 'v8'

module Spade
  # find the current path with a package.json or .packages or cur_path
  def self.discover_root(cur_path)
    ret = File.expand_path(cur_path)
    while ret != '/' && ret != '.'
      return ret if File.exists?(File.join(ret,'package.json')) || File.exists?(File.join(ret,'.spade'))
      ret = File.dirname ret
    end

    return cur_path
  end
end

require 'spade/bundle'
require 'spade/repository'

require 'spade/cli'
require 'spade/context'
require 'spade/credentials'
require 'spade/environment'
require 'spade/exports'
require 'spade/local'
require 'spade/package'
require 'spade/remote'
require 'spade/shell'
require 'spade/version'
