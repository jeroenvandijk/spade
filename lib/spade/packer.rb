module Spade
  class Packer
    def initialize(path, email)
      @path  = path
      @email = email
    end

    METADATA = %w[keywords licenses engines main bin]

    def transform
      Gem::Specification.new do |spec|
        spec.name         = package["name"]
        spec.version      = package["version"]
        spec.authors      = [package["author"]]
        spec.email        = @email
        spec.homepage     = package["homepage"]
        spec.summary      = package["description"]
        spec.description  = package["description"]
        spec.requirements = [metadata.to_json]
        spec.files        = glob_javascript(lib_path) + bin_files
        spec.test_files   = glob_javascript(test_path)
      end
    end

    private

    def glob_javascript(path)
      Dir[File.join(path, "**", "*.js")]
    end

    def bin_files
      package["bin"].values
    end

    def lib_path
      package["directories"]["lib"]
    end

    def test_path
      package["directories"]["test"]
    end

    def metadata
      Hash[*package.select { |k, v| METADATA.include?(k) }.flatten(1)]
    end

    def package
      @package ||= JSON.parse(File.read(@path))
    end
  end
end
