module Spade
  class Package
    METADATA = %w[keywords licenses engines main bin]
    FIELDS   = %w[name version description author homepage description directories bin]
    attr_accessor :metadata
    attr_accessor *FIELDS

    def initialize(path, email)
      @email = email
      self.attributes = JSON.parse(File.read(path))
    end

    def attributes=(attrs)
      FIELDS.each do |field|
        send("#{field}=", attrs[field])
      end
      self.metadata = Hash[*attrs.select { |k, v| METADATA.include?(k) }.flatten(1)]
    end

    def to_spec
      Gem::Specification.new do |spec|
        spec.name         = name
        spec.version      = version
        spec.authors      = [author]
        spec.email        = @email
        spec.homepage     = homepage
        spec.summary      = description
        spec.description  = description
        spec.requirements = [metadata.to_json]
        spec.files        = glob_javascript(lib_path) + bin_files
        spec.test_files   = glob_javascript(test_path)
        def spec.file_name
          full_name + ".spd"
        end
      end
    end

    private

    def glob_javascript(path)
      Dir[File.join(path, "**", "*.js")]
    end

    def bin_files
      bin.values
    end

    def lib_path
      directories["lib"]
    end

    def test_path
      directories["test"]
    end
  end
end
