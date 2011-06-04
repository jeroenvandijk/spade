Bundler.require :default, :development

require 'support/cli'
require 'support/fake'
require 'support/fake_gem_server'
require 'support/fake_gemcutter'
require 'support/matchers'
require 'support/path'

RSpec.configure do |config|
  working_dir = Dir.pwd

  config.include SpecHelpers

  config.around do |blk|
    reset!

    blk.call

    kill!
    stop_fake
    Dir.chdir working_dir if Dir.pwd != working_dir
  end
end

