class FakeGemServer
  include SpecHelpers

  def call(env)
    request = Rack::Request.new(env)

    if request.path =~ /latest_specs/
      latest_index = [
        ["builder", Gem::Version.new("3.0.0"), "ruby"],
        ["rake",    Gem::Version.new("0.8.7"), "ruby"]
      ]
      [200, {"Content-Type" => "application/octet-stream"}, compress(latest_index)]
    elsif request.path =~ /specs/
      big_index = [
        ["builder", Gem::Version.new("3.0.0"), "ruby"],
        ["rake",    Gem::Version.new("0.8.7"), "ruby"],
        ["rake",    Gem::Version.new("0.8.6"), "ruby"]
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
