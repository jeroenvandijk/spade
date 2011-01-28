require "spec_helper"

describe "spade uninstall" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    env["RUBYGEMS_HOST"] = "http://localhost:9292"
    env["GEM_HOME"] = spade_dir.to_s
    env["GEM_PATH"] = spade_dir.to_s
    start_fake(FakeGemServer.new)
  end

  it "uninstalls a gem" do
    spade "install", "rake"

    stdout.read.should include("Successfully installed rake-0.8.7")

    "rake-0.8.7".should be_fetched
    "rake-0.8.7".should be_unpacked

    spade "uninstall", "rake"

    stdout.read.should include("Successfully uninstalled rake-0.8.7")

    "rake-0.8.7".should_not be_fetched
    "rake-0.8.7".should_not be_unpacked
  end
end
