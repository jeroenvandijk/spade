require 'spade/core'
require 'libgems'

begin
  require 'spade/packager'
rescue LoadError
  # Packager isn't necessary, but we should use it if available
end

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
