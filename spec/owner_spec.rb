require "spec_helper"

describe "spade owner" do
  let(:api_key) { "deadbeef" }
  let(:creds)   { spade_dir("credentials") }

  before do
    cd(home)

    fake = lambda do |env|
      request = Rack::Request.new(env)

      if request.path == "/api/v1/gems/rake/owners"
        if request.env["HTTP_AUTHORIZATION"] == api_key
          if request.post?
            [200, {"Content-Type" => "text/plain"}, "Owner added successfully."]
          elsif request.delete?
            [200, {"Content-Type" => "text/plain"}, "Owner removed successfully."]
          end
        else
          [401, {"Content-Type" => "text/plain"}, "One cannot simply walk into Mordor!"]
        end
      elsif request.path == "/api/v1/gems/rake/owners.yaml" &&
        request.get? &&
        request.env["HTTP_AUTHORIZATION"] == api_key

        yaml = YAML.dump([{'email' => 'geddy@example.com'}, {'email' => 'lerxst@example.com'}])
        [200, {"Content-Type" => "text/plain"}, yaml]
      else
        [401, {"Content-Type" => "text/plain"}, "One cannot simply walk into Mordor!"]
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

    it "registers new owners if package is owned" do
      spade "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("Owner added successfully.")
    end

    it "removes owners if package is owned" do
      spade "owner", "remove", "rake", "geddy@example.com"

      stdout.read.should include("Owner removed successfully.")
    end

    it "lists owners for a gem" do
      spade "owner", "list", "rake"

      stdout.read.should == <<EOF
Owners for package: rake
- geddy@example.com
- lerxst@example.com
EOF
    end
  end

  context "with wrong api key" do
    before do
      write_api_key("beefbeef")
    end

    it "shows rejection message for add if wrong api key is supplied" do
      spade "owner", "add", "rake", "geddy@example.com"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end

    it "shows rejection message for remove if wrong api key is supplied" do
      spade "owner", "remove", "rake", "geddy@example.com"

      stdout.read.should include("One cannot simply walk into Mordor!")
    end

    it "shows rejection message for list if wrong api key is supplied" do
      spade "owner", "list", "rake"

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

  it "asks for login first if api key does not exist" do
    spade "owner", "remove", "rake", "geddy@example.com"

    stdout.read.should include("Please login first with `spade login`")
  end

  it "asks for login first if api key does not exist" do
    spade "owner", "list", "rake"

    stdout.read.should include("Please login first with `spade login`")
  end

  it "requires a package name for add" do
    spade "owner", "add", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for remove" do
    spade "owner", "remove", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for list" do
    spade "owner", "list", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end

  it "requires a package name for list with default command" do
    spade "owner", :track_stderr => true

    stderr.read.should include("called incorrectly")
  end
end
