module Spade
  class Package
    EXT      = "spd"
    METADATA = %w[keywords licenses engines main bin directories]
    FIELDS   = %w[name version description author homepage summary]
    attr_accessor :metadata, :bin_files, :lib_path, :test_path, :errors, :json_path, :attributes
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

    def to_full_name
      "#{name}-#{version}"
    end

    def to_ext
      "#{self.to_full_name}.#{EXT}"
    end

    def errors
      @errors ||= []
    end

    def validate
      read && parse && validate_fields && validate_version
    end

    def valid?
      validate == true
    end

    private

    def parse
      FIELDS.each do |field|
        send("#{field}=", @attributes[field])
      end
      self.bin_files = @attributes["bin"].values
      self.lib_path  = @attributes["directories"]["lib"]
      self.test_path = @attributes["directories"]["test"]
      self.metadata  = Hash[*@attributes.select { |k, v| METADATA.include?(k) }.flatten(1)]
    end

    def read
      @attributes = JSON.parse(File.read(@json_path))
    rescue *[JSON::ParserError, Errno::EACCES, Errno::ENOENT] => ex
      add_error "There was a problem parsing package.json: #{ex.message}"
    end

    def validate_version
      Gem::Version.new(version)
      true
    rescue ArgumentError => ex
      add_error ex.to_s
    end

    def validate_fields
      %w[name description summary homepage author version].all? do |field|
        value = send(field)
        if value.nil? || value == ""
          add_error "Package requires a '#{field}' field."
        else
          true
        end
      end
    end

    def add_error(message)
      self.errors << message
      false
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
