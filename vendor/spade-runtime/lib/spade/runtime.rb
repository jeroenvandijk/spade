require 'spade/core'
require 'spade/packager'
require 'spade/ruby' # Should we always require this?

module Spade
  module Runtime
    JSPATH = File.expand_path("../runtime/js/spade.js", __FILE__)

    autoload :Bundle,     'spade/runtime/bundle'
    autoload :Context,    'spade/runtime/context'
    autoload :MainContext,'spade/runtime/context'
    autoload :Server,     'spade/runtime/server'
    autoload :Shell,      'spade/runtime/shell'
    autoload :CLI,        'spade/runtime/cli'
  end
end
