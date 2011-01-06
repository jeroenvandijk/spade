require "spec_helper"

describe "logging in" do
  let(:email)    { "email@example.com" }
  let(:password) { "secrets" }
  let(:url)      { "http://#{email}:#{password}@sproutcutter.heroku.com/api/v1/api_key" }
  let(:api_key)  { "deadbeef" }
  let(:creds)    { home(".spade", "credentials") }

  before do
    cd(home)

    fake = lambda { |env|
      [200, {"Content-Type" => "text/plain"}, [api_key]]
    }

    protected_fake = Rack::Auth::Basic.new(fake) do |user, pass|
      user == email && password == pass
    end

    env["HOME"] = home.to_s
    env["SPADE_URL"] = "http://localhost:9292"
    start_fake(protected_fake)
  end

  after do
    stop_fake
  end

  it "first asks for credentials" do
    spade "login"
    stdout.should contain_line("Enter your Spade credentials.")
  end

  it "says email that user is logging in as" do
    spade "login"
    input email
    input password
    stdout.read.should include("Logging in as #{email}...")
  end

  it "makes a request out for the api key and stores it in ~/.spade/credentials" do
    spade "login"
    input email
    input password

    stdout.read.should include("Logged in!")
    File.exist?(creds).should be_true
    YAML.load_file(creds)[:spade_api_key].should == api_key
  end

  it "notifies user if bad creds given" do
    spade "login"
    input email
    input "badpassword"

    stdout.read.should include("Incorrect email or password.")
    File.exist?(creds).should be_false
  end
end
