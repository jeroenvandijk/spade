require 'spade/core'
require 'spade/packager'
require 'spade/ruby' # Should we always require this?

module Spade
  module Runtime
    autoload :Bundle,     'spade/runtime/bundle'
    autoload :Context,    'spade/runtime/context'
    autoload :MainContext,'spade/runtime/context'
    autoload :Server,     'spade/runtime/server'
    autoload :Shell,      'spade/runtime/shell'
    autoload :CLI,        'spade/runtime/cli'
    autoload :Namespace,  'spade/runtime/exports'
    autoload :Exports,    'spade/runtime/exports'
  end
end
