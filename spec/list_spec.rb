require "spec_helper"

describe "listing gems" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    start_fake(FakeGemServer.new)
  end

  it "lists latest gems by default" do
    spade "list"

    output = stdout.read
    output.should include("builder (3.0.0)")
    output.should include("rake (0.8.7)")
  end
end
