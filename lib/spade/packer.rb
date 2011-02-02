module Spade
  class Packer
    def initialize(path, email)
      @path  = path
      @email = email
    end

    METADATA = %w[keywords licenses engines main bin]

    def transform
      package  = JSON.parse(File.read(@path))
      metadata = Hash[*package.select { |k, v| METADATA.include?(k) }.flatten(1)]

      Gem::Specification.new do |spec|
        spec.name         = package["name"]
        spec.version      = package["version"]
        spec.authors      = [package["author"]]
        spec.email        = @email
        spec.homepage     = package["homepage"]
        spec.summary      = package["description"]
        spec.description  = package["description"]
        spec.requirements = [metadata.to_json]
      end
    end
  end
end
