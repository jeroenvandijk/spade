require "spec_helper"

describe "spade build when logged in" do
  let(:email) { "who@example.com" }

  before do
    cd(home)
    env["HOME"] = home.to_s
    write_creds(email, "deadbeef")
  end

  it "builds a spade from a given package.json" do
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
    package.spec.email.should == email
  end
end

describe "spade build without logging in" do
  before do
    cd(home)
    env["HOME"] = home.to_s
  end

  it "warns the user that they must log in first" do
    spade "build", :track_stderr => true

    exit_status.should_not be_success
    stderr.read.should include("Please login first with `spade login`")
  end
end

describe "spade build with an invalid package.json" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    write_api_key("deadbeef")
  end

  it "reports error messages" do
    FileUtils.touch "package.json"
    spade "build", :track_stderr => true

    exit_status.should_not be_success
    output = stderr.read
    output.should include("Spade encountered the following problems building your package:")
    output.should include("There was a problem parsing package.json")
  end
end
