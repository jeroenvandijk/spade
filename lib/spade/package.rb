module Spade
  class Package
    METADATA = %w[keywords licenses engines main bin directories]
    FIELDS   = %w[name version description author homepage description summary]
    attr_accessor :metadata, :bin_files, :lib_path, :test_path
    attr_accessor *FIELDS

    def initialize(email = "")
      @email = email
    end

    def json=(path)
      self.attributes = JSON.parse(File.read(path))
    end

    def spade=(path)
      format = Gem::Format.from_file_by_path(path)
      fill_from_gemspec(format.spec)
    end

    def attributes=(attrs)
      FIELDS.each do |field|
        send("#{field}=", attrs[field])
      end
      self.bin_files = attrs["bin"].values
      self.lib_path  = attrs["directories"]["lib"]
      self.test_path = attrs["directories"]["test"]
      self.metadata  = Hash[*attrs.select { |k, v| METADATA.include?(k) }.flatten(1)]
    end

    def to_spec
      Gem::Specification.new do |spec|
        spec.name         = name
        spec.version      = version
        spec.authors      = [author]
        spec.email        = @email
        spec.homepage     = homepage
        spec.summary      = summary
        spec.description  = description
        spec.requirements = [metadata.to_json]
        spec.files        = glob_javascript(lib_path) + bin_files
        spec.test_files   = glob_javascript(test_path)
        def spec.file_name
          full_name + ".spd"
        end
      end
    end

    def as_json(options = {})
      FIELDS.inject(self.metadata) do |json, key|
        json[key] = send(key)
        json
      end
    end

    def to_s
      "#{name}-#{version}"
    end

    private

    def glob_javascript(path)
      Dir[File.join(path, "**", "*.js")]
    end

    def fill_from_gemspec(spec)
      FIELDS.each do |field|
        send("#{field}=", spec.send(field).to_s)
      end
      self.metadata = JSON.parse(spec.requirements.first)
    end
  end
end
