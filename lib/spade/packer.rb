module Spade
  class Packer
    def initialize(path)
      @path = path
    end

    def transform
      package = JSON.parse(File.read(@path))
      Gem::Specification.new do |spec|
        spec.name    = package["name"]
        spec.version = package["version"]
        spec.authors = [package["author"]]
      end
    end
  end
end
