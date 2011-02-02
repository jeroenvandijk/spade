require "spec_helper"

describe Spade::Packer do
  subject do
    Spade::Packer.new(fixtures("package.json"))
  end

  it "transforms a package.json into a gemspec" do
    gemspec = subject.transform
    gemspec.class.should == Gem::Specification

    gemspec.name.should     == "coffee-script"
    gemspec.version.should  == Gem::Version.new("1.0.1.pre")
    gemspec.authors.should  == ["Jeremy Ashkenas"]
  end
end
