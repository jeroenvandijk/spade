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

  it "registers a gem when sent with the right api key" do
    FileUtils.mkdir_p(home(".spade"))
    File.open(home(".spade", "credentials"), "w") do |file|
      file.write YAML.dump(:spade_api_key => api_key)
    end

    spade "push", "../../spec/fixtures/rake-0.8.7.gem"

    stdout.should contain_line("Successfully registered rake (0.8.7)")
  end
end
