require "spec_helper"

describe "installing gems" do
  before do
    cd(home)

    fake = lambda do |env|
      request  = Rack::Request.new(env)

      if request.path =~ /specs/
        index = [
          ["builder", Gem::Version.new("3.0.0"), "ruby"],
          ["rake",    Gem::Version.new("0.8.7"), "ruby"]
        ]
        compressed = StringIO.new
        gzip = Zlib::GzipWriter.new(compressed)
        gzip.write(Marshal.dump(index))
        gzip.close

        [200, {"Content-Type" => "application/octet-stream"}, compressed.string]
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

    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    start_fake(fake)
  end

  it "installs a valid gem" do
    spade "install", "rake"

    stdout.read.should include("Successfully installed rake-0.8.7")

    "rake-0.8.7".should be_fetched
    "rake-0.8.7".should be_unpacked
  end

  it "installs a multiple gems" do
    spade "install", "rake", "builder"

    output = stdout.read

    %w[builder-3.0.0 rake-0.8.7].each do |pkg|
      output.should include("Successfully installed #{pkg}")
      pkg.should be_fetched
      pkg.should be_unpacked
    end
  end

  it "installs valid gems while ignoring invalid ones" do
    spade "install", "rake", "fake"

    output = stdout.read
    output.should include("Can't find package fake")
    output.should include("Successfully installed rake-0.8.7")

    "rake-0.8.7".should be_fetched
    "rake-0.8.7".should be_unpacked
    "fake-0".should_not be_fetched
    "fake-0".should_not be_unpacked
  end

  it "fails when installing an invalid gem" do
    spade "install", "fake"

    stdout.read.should include("Can't find package fake")
    "rake-0.8.7".should_not be_fetched
    "rake-0.8.7".should_not be_unpacked
    "fake-0".should_not be_fetched
    "fake-0".should_not be_unpacked
  end

  it "fails if spade can't write to the spade directory" do
    FileUtils.mkdir_p home(".spade")
    FileUtils.chmod 0555, home(".spade")

    spade "install", "rake"

    stdout.read.should include("You don't have write permissions")

    "rake-0.8.7".should_not be_fetched
    "rake-0.8.7".should_not be_unpacked
  end
end
