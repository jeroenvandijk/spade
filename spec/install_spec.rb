require "spec_helper"

describe "installing gems" do
  before do
    cd(home)

    fake = lambda do |env|
      request  = Rack::Request.new(env)
      gem_path = fixtures("rake-0.8.7.gem")

      if request.path =~ /specs/
        index = [["rake", Gem::Version.new("0.8.7"), "ruby"]]
        compressed = StringIO.new
        gzip = Zlib::GzipWriter.new(compressed)
        gzip.write(Marshal.dump(index))
        gzip.close

        [200, {"Content-Type" => "application/octet-stream"}, compressed.string]
      elsif request.path =~ /gemspec/
        spec  = Gem::Format.from_file_by_path(gem_path.to_s).spec
        value = Gem.deflate(Marshal.dump(spec))

        [200, {"Content-Type" => "application/octet-stream"}, value]
      elsif request.path =~ /\.gem$/
        [200, {"Content-Type" => "application/octet-stream"}, File.read(gem_path)]
      else
        [200, {"Content-Type" => "text/plain"}, "fake gem server"]
      end
    end

    env["HOME"] = home.to_s
    env["SPADE_URL"] = "http://localhost:9292"
    start_fake(fake)
  end

  it "installs a valid gem" do
    spade "install", "rake"

    stdout.should contain_line("Successfully installed rake-0.8.7")
    File.directory?(home(".spade", "gems", "rake-0.8.7")).should be_true
    File.exist?(home(".spade", "cache", "rake-0.8.7.gem")).should be_true
  end

  it "fails when installing an invalid gem" do
    spade "install", "fake"

    stdout.should contain_line("Can't find package fake")
    File.directory?(home(".spade", "gems", "rake-0.8.7")).should be_false
    File.exist?(home(".spade", "cache", "rake-0.8.7.gem")).should be_false
  end

  it "fails if spade can't write to the spade directory" do
    FileUtils.mkdir_p home(".spade")
    FileUtils.chmod 0555, home(".spade")

    spade "install", "rake"

    stdout.read.should include("You don't have write permissions")

    File.directory?(home(".spade", "gems", "rake-0.8.7")).should be_false
    File.exist?(home(".spade", "cache", "rake-0.8.7.gem")).should be_false
  end
end
