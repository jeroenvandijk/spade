require "spec_helper"

describe "spade build the gauntlet" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    write_creds("user@example.com", "deadbeef")
  end

  it "builds a spade from optparse" do
    FileUtils.cp_r root.join("packages/optparse"), "optparse"
    cd "optparse"
    spade "build"

    exit_status.should be_success
    stdout.read.should include("Successfully built package: optparse-1.0.1.spd")
    File.exist?(tmp.join("optparse", "optparse-1.0.1.spd"))
  end
end
