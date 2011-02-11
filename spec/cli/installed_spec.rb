require "spec_helper"

describe "spade installed" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    env["GEM_HOME"] = spade_dir.to_s
    env["GEM_PATH"] = spade_dir.to_s
    start_fake(FakeGemServer.new)
  end

  it "lists installed gems" do
    spade "install", "rake"
    wait
    spade "installed"

    output = stdout.read
    output.should include("rake (0.8.7)")
    output.should_not include("0.8.6")
    output.should_not include("builder")
    output.should_not include("bundler")
    output.should_not include("highline")
  end
end
