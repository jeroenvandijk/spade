require "spec_helper"

describe "spade build" do
  before do
    cd(home)
    env["HOME"] = home.to_s
  end

  it "builds a gem from a given package.json" do
    FileUtils.cp_r fixtures("coffee"), "."
    FileUtils.cp fixtures("package.json"), "coffee"
    cd "coffee"
    spade "build"

    exit_status.should be_success
    output = stdout.read
    output.should include("Successfully built package: coffee-1.0.1.pre.spd")

    package = Gem::Format.from_file_by_path("coffee-1.0.1.pre.spd")
    package.spec.name.should == "coffee"
    package.spec.version.should == Gem::Version.new("1.0.1.pre")
  end
end
