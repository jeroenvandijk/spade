class FakeGemServer
  include SpecHelpers

  def index(name, version)
    [name, Gem::Version.new(version), "ruby"]
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /latest_specs/
      latest_index = [
        index("builder",  "3.0.0"),
        index("highline", "1.6.1"),
        index("rake",     "0.8.7"),
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(latest_index)]
    elsif request.path =~ /specs/
      big_index = [
        index("builder",  "3.0.0"),
        index("highline", "1.6.1"),
        index("rake",     "0.8.7"),
        index("rake",     "0.8.6"),
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(big_index)]
    elsif request.path =~ /\/quick\/Marshal\.4\.8\/(.*\.gem)spec\.rz$/
      spec  = Gem::Format.from_file_by_path(fixtures($1).to_s).spec
      value = Gem.deflate(Marshal.dump(spec))

      [200, {"Content-Type" => "application/octet-stream"}, value]
    elsif request.path =~ /\/gems\/(.*\.gem)$/
      [200, {"Content-Type" => "application/octet-stream"}, File.read(fixtures($1))]
    else
      [200, {"Content-Type" => "text/plain"}, "fake gem server"]
    end
  end

  def compress(index)
    compressed = StringIO.new
    gzip = Zlib::GzipWriter.new(compressed)
    gzip.write(Marshal.dump(index))
    gzip.close
    compressed.string
  end
end
