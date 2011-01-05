# ==========================================================================
# Project:   Spade - CommonJS Runtime
# Copyright: ©2010 Strobe Inc. All rights reserved.
# License:   Licened under MIT license (see LICENSE)
# ==========================================================================

require 'rubygems'
require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'

require 'eventmachine'
require 'thor'
require 'v8'

module Spade
  SPADE_DIR = '.spade'

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
require 'spade/cli'
require 'spade/context'
require 'spade/exports'
require 'spade/remote'
require 'spade/shell'
require 'spade/version'
