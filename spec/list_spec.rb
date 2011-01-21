require "spec_helper"

describe "spade list" do
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

  it "lists all gems when given the all argument" do
    spade "list", "-a"

    output = stdout.read
    output.should include("builder (3.0.0)")
    output.should include("rake (0.8.7, 0.8.6)")
  end

  it "filters gems when given an argument" do
    spade "list", "builder"

    output = stdout.read
    output.should include("builder (3.0.0)")
    output.should_not include("rake")
  end

  it "filters gems when given an argument and shows all versions" do
    spade "list", "rake", "-a"

    output = stdout.read
    output.should include("rake (0.8.7, 0.8.6)")
    output.should_not include("builder")
  end

  it "filters multiple gems" do
    spade "list", "rake", "highline"

    output = stdout.read
    output.should include("highline (1.6.1)")
    output.should include("rake (0.8.7)")
    output.should_not include("builder")
  end

  it "says it couldn't find any if none found" do
    spade "list", "rails", :track_stderr => true

    stderr.read.strip.should == 'No packages found matching "rails".'
    exit_status.should_not be_success
  end

  it "says it couldn't find any if none found matching multiple packages" do
    spade "list", "rails", "bake", :track_stderr => true

    stderr.read.strip.should == 'No packages found matching "rails", "bake".'
    exit_status.should_not be_success
  end
end
