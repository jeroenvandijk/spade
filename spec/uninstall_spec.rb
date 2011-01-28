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

  it "uninstalls multiple packages" do
    spade "install", "rake", "highline"
    output = stdout.read

    "rake-0.8.7".should be_fetched
    "rake-0.8.7".should be_unpacked
    "highline-1.6.1".should be_fetched
    "highline-1.6.1".should be_unpacked

    spade "uninstall", "rake", "highline"

    output = stdout.read
    output.should include("Successfully uninstalled rake-0.8.7")
    output.should include("Successfully uninstalled highline-1.6.1")

    "rake-0.8.7".should_not be_fetched
    "rake-0.8.7".should_not be_unpacked
    "highline-1.6.1".should_not be_fetched
    "highline-1.6.1".should_not be_unpacked
  end

  it "requires at least one package to uninstall" do
    spade "uninstall", :track_stderr => true
    stderr.read.should include("called incorrectly")
  end
end
