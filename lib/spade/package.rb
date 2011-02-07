module Spade
  class Package
    EXT      = "spd"
    METADATA = %w[keywords licenses engines main bin directories]
    FIELDS   = %w[name version description author homepage description summary]
    attr_accessor :metadata, :bin_files, :lib_path, :test_path, :errors, :json_path
    attr_accessor *FIELDS

    def initialize(email = "")
      @email = email
    end

    def spade=(path)
      format = Gem::Format.from_file_by_path(path)
      fill_from_gemspec(format.spec)
    end

    def to_spec
      validate
      Gem::Specification.new do |spec|
        spec.name              = name
        spec.version           = version
        spec.authors           = [author]
        spec.email             = @email
        spec.homepage          = homepage
        spec.summary           = summary
        spec.description       = description
        spec.requirements      = [metadata.to_json]
        spec.files             = glob_javascript(lib_path) + bin_files
        spec.test_files        = glob_javascript(test_path)
        spec.rubyforge_project = "spade"
        def spec.file_name
          "#{full_name}.#{EXT}"
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

    def to_ext
      "#{self}.#{EXT}"
    end

    def errors
      @errors ||= []
    end

    def parse
      attrs = JSON.parse(File.read(@json_path))
      FIELDS.each do |field|
        send("#{field}=", attrs[field])
      end
      self.bin_files = attrs["bin"].values
      self.lib_path  = attrs["directories"]["lib"]
      self.test_path = attrs["directories"]["test"]
      self.metadata  = Hash[*attrs.select { |k, v| METADATA.include?(k) }.flatten(1)]
    end

    def validate
      begin
        parse && validate_fields
      rescue *[JSON::ParserError, Errno::EACCES, Errno::ENOENT] => ex
        add_error "There was a problem parsing package.json: #{ex.message}"
      end
    end

    def valid?
      validate == true
    end

    private

    def add_error(message)
      self.errors << message
      false
    end

    def validate_fields
      if self.name.nil?
        add_error "Package requires a 'name' field as a string."
      else
        true
      end
    end
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
