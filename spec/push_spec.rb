require "spec_helper"

describe "pushing a gem" do
  let(:url)      { "http://#{email}:#{password}@sproutcutter.heroku.com/api/v1/api_key" }
  let(:api_key)  { "deadbeef" }
  let(:creds)    { home(".spade", "credentials") }

  before do
    cd(home)

    fake = lambda { |env|
      request = Rack::Request.new(env)

      if request.env["HTTP_AUTHORIZATION"] == api_key
        [200, {"Content-Type" => "text/plain"}, "Successfully registered rake (0.8.7)"]
      else
        [401, {"Content-Type" => "text/plain"}, "One cannot simply walk into Mordor!"]
      end
    }

    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    start_fake(fake)
  end

  context "with a good api key" do
    before do
      FileUtils.mkdir_p(home(".spade"))
      File.open(home(".spade", "credentials"), "w") do |file|
        file.write YAML.dump(:spade_api_key => api_key)
      end
    end

    it "registers a gem when sent with the right api key" do
      spade "push", "../../spec/fixtures/rake-0.8.7.gem"

      stdout.read.should include("Successfully registered rake (0.8.7)")
    end

    it "ignores files that don't exist" do
      spade "push", "rake-1.0.0.gem"

      stdout.read.should include("No such file")
    end

    it "must push a valid gem" do
      spade "push", "../../spec/fixtures/badrake-0.8.7.gem"

      stdout.read.should include("There was a problem opening your package.")
    end

    it "does not allow pushing of random files" do
      spade "push", "../../Rakefile"

      stdout.read.should include("There was a problem opening your package.")
    end
  end

  it "shows rejection message if wrong api key is supplied" do
    FileUtils.mkdir_p(home(".spade"))
    File.open(home(".spade", "credentials"), "w") do |file|
      file.write YAML.dump(:spade_api_key => "beefbeef")
    end

    spade "push", "../../spec/fixtures/rake-0.8.7.gem"

    stdout.read.should include("One cannot simply walk into Mordor!")
  end

  it "asks for login first if api key does not exist" do
    spade "push", "../../spec/fixtures/rake-0.8.7.gem"

    stdout.read.should include("Please login first with `spade login`")
  end
end
