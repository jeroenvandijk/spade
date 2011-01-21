require "spec_helper"

describe "spade owner" do
  let(:api_key) { "deadbeef" }
  let(:creds)   { spade_dir("credentials") }

  before do
    cd(home)

    fake = lambda do |env|
      request = Rack::Request.new(env)

      if request.path == "/api/v1/gems/rake/owners" && request.post?
        if request.env["HTTP_AUTHORIZATION"] == api_key
          [200, {"Content-Type" => "text/plain"}, "Owner added successfully."]
        else
          [401, {"Content-Type" => "text/plain"}, "One cannot simply walk into Mordor!"]
        end
      end
    end

    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    start_fake(fake)
  end

  context "with a good api key" do
    before do
      write_api_key(api_key)
    end

    it "registers new owners if gem is owned" do
      spade "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("Owner added successfully.")
    end
  end

  context "with wrong api key" do
    before do
      write_api_key("beefbeef")
    end

    it "shows rejection message if wrong api key is supplied" do
      spade "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end
  end
end

describe "spade owner with wrong arguments" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
  end

  it "asks for login first if api key does not exist" do
    spade "owner", "add", "rake", "geddy@example.com"

    stdout.read.should include("Please login first with `spade login`")
  end

  it "requires a package name" do
    spade "owner", "add", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end
end
