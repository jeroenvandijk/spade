require "spec_helper"

describe "spade build the gauntlet" do
  before do
    cd(home)
    env["HOME"] = home.to_s
    write_creds("user@example.com", "deadbeef")
  end

  {
    "ivory"    => "0.0.1",
    "optparse" => "1.0.1",
  }.each do |package, version|
    it "builds a spade from #{package}" do
      FileUtils.cp_r root.join("packages/#{package}"), package
      cd package
      spade "build"

      exit_status.should be_success
      stdout.read.should include("Successfully built package: #{package}-#{version}.spd")
      File.exist?(tmp.join(package, "#{package}-#{version}.spd"))
    end
  end
end
