require "spec_helper"

describe "spade unpack" do
  before do
    cd(home)
    env["HOME"] = home.to_s
  end

  it "builds a gem from a given package.json" do
    FileUtils.cp fixtures("coffee-1.0.1.pre.spd"), "."
    spade "unpack", "coffee-1.0.1.pre.spd"

    exit_status.should be_success
    output = stdout.read
    output.should include("Unpacked spade into: #{Dir.pwd}/coffee-1.0.1.pre")

    home("coffee-1.0.1.pre/bin/coffee").should exist
    home("coffee-1.0.1.pre/lib/coffee.js").should exist
    home("coffee-1.0.1.pre/lib/coffee/base.js").should exist
    home("coffee-1.0.1.pre/lib/coffee/mocha/chai.js").should exist
    home("coffee-1.0.1.pre/qunit/coffee/test.js").should exist
    home("coffee-1.0.1.pre/qunit/test.js").should exist
  end

  it "can unpack to a different directory" do
    FileUtils.cp fixtures("coffee-1.0.1.pre.spd"), "."
    spade "unpack", "coffee-1.0.1.pre.spd", "--target", "star/bucks"

    exit_status.should be_success
    output = stdout.read
    output.should include("Unpacked spade into: #{Dir.pwd}/star/bucks/coffee-1.0.1.pre")

    home("star/bucks/coffee-1.0.1.pre/bin/coffee").should exist
  end
end
