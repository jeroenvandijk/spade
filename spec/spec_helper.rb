require 'spade'
require 'spade/cli'

Dir[File.expand_path("../support/*.rb", __FILE__)].each do |file|
  require file
end

RSpec.configure do |config|
  working_dir = Dir.pwd

  config.include SpecHelpers

  config.around do |blk|
    reset!
    blk.call
    kill!
    Dir.chdir working_dir if Dir.pwd != working_dir
  end
end
