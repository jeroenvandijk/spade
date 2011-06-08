require 'libgems'

module Spade
  module Packager
    SPADE_DIR = '.spade' # Would be nice to share this with node.js loader
    TEMPLATES_DIR = File.expand_path("../../../templates", __FILE__)

    autoload :CLI,                  'spade/packager/cli'
    autoload :Credentials,          'spade/packager/credentials'
    autoload :DependencyInstaller,  'spade/packager/dependency_installer'
    autoload :Environment,          'spade/packager/environment'
    autoload :Installer,            'spade/packager/installer'
    autoload :Local,                'spade/packager/local'
    autoload :Package,              'spade/packager/package'
    autoload :Remote,               'spade/packager/remote'
    autoload :Repository,           'spade/packager/repository'
    autoload :Version,              'spade/packager/version'
  end
end

