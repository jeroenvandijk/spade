require "spec_helper"

describe Spade::Package, "#to_spec" do
  let(:email) { "user@example.com" }

  before do
    cd(home)
    FileUtils.mkdir_p(home("lib"))
    FileUtils.mkdir_p(home("qunit"))
  end

  subject do
    package = Spade::Package.new(email)
    package.json_path = fixtures("package.json")
    package.to_spec
  end

  it "transforms the name" do
    subject.name.should == "coffee"
  end

  it "transforms the version" do
    subject.version.should == Gem::Version.new("1.0.1.pre")
  end

  it "transforms the author" do
    subject.authors.should == ["Jeremy Ashkenas"]
  end

  it "transforms the email" do
    subject.email.should == email
  end

  it "transforms the homepage" do
    subject.homepage.should == "http://github.com/jashkenas/coffee-script"
  end

  it "transforms the description" do
    subject.description.should include("little language")
  end

  it "transforms the description" do
    subject.summary.should == "Unfancy JavaScript"
  end

  it "packs metadata into requirements" do
    metadata = JSON.parse(subject.requirements.first)
    metadata["keywords"].should == %w[javascript language coffeescript compiler]
    metadata["licenses"].should == [
      {"type" => "MIT",
       "url"  => "http://github.com/jashkenas/coffee-script/raw/master/LICENSE"}
    ]
    metadata["engines"].should == {"node" => ">=0.2.5"}
    metadata["main"].should == "./lib/coffee-script"
    metadata["bin"].should == {"coffee" => "./bin/coffee", "cake" => "./bin/cake"}
  end

  def expand_sort(files)
    files.map { |f| File.expand_path(f) }.sort
  end

  it "expands paths from the directories" do
    others     = ["lib/coffee.png", "qunit/test.log"]
    files      = ["bin/coffee", "bin/cake", "lib/coffee.js", "lib/coffee/base.js", "lib/coffee/mocha/chai.js"]
    test_files = ["qunit/test.js", "qunit/coffee/test.js"]

    FileUtils.mkdir_p(["bin/", "lib/coffee/", "lib/coffee/mocha", "qunit/", "qunit/coffee"])
    FileUtils.touch(files + test_files + others)

    expand_sort(subject.files).should == expand_sort(files + test_files)
    expand_sort(subject.test_files).should == expand_sort(test_files)
  end

  it "hacks the file name to return .spd" do
    subject.file_name.should == "coffee-1.0.1.pre.spd"
  end

  it "sets the rubyforge_project to appease older versions of rubygems" do
    subject.rubyforge_project.should == "spade"
  end
end

describe Spade::Package, "#to_s" do
  let(:email) { "user@example.com" }

  subject do
    package = Spade::Package.new
    package.json_path = fixtures("package.json")
    package.valid?
    package
  end

  it "gives the name and version" do
    subject.to_full_name.should == "coffee-1.0.1.pre"
  end
end

describe Spade::Package, "converting" do
  before do
    cd(home)
  end

  subject do
    package = Spade::Package.new
    package.spade = fixtures("coffee-1.0.1.pre.spd")
    package.as_json
  end

  it "can recreate the same package.json from the package" do
    subject.should == JSON.parse(File.read(fixtures("package.json")))
  end
end

describe Spade::Package, "validating" do
  before do
    cd(home)
  end

  subject { Spade::Package.new }

  shared_examples_for "a good parser" do
    it "had a problem parsing package.json" do
      subject.should have_error("There was a problem parsing package.json")
    end
  end

  context "with a blank file" do
    before do
      FileUtils.touch("package.json")
      subject.json_path = "package.json"
    end
    it_should_behave_like "a good parser"
  end

  context "with bad json" do
    before do
      File.open("package.json", "w") do |f|
        f.write "---bad json---"
      end
      subject.json_path = "package.json"
    end
    it_should_behave_like "a good parser"
  end

  context "json can't be read" do
    before do
      FileUtils.cp fixtures("package.json"), "."
      FileUtils.chmod 0000, "package.json"
      subject.json_path = "package.json"
    end
    it_should_behave_like "a good parser"
  end

  context "json can't be found" do
    before do
      subject.json_path = "package.json"
    end
    it_should_behave_like "a good parser"
  end

end

describe Spade::Package, "validation errors" do
  let(:email) { "user@example.com" }

  before do
    cd(home)
    FileUtils.mkdir_p(home("lib"))
    FileUtils.mkdir_p(home("qunit"))
  end

  subject do
    Spade::Package.new(email)
  end

  def write_package
    path    = home("package.json")
    package = JSON.parse(File.read(fixtures("package.json")))
    yield package
    File.open(path, "w") do |file|
      file.write package.to_json
    end
    subject.json_path = path
  end

  %w[name description summary homepage author version directories].each do |field|
    it "is invalid without a #{field} field" do
      write_package do |package|
        package.delete(field)
      end

      subject.should have_error("Package requires a '#{field}' field")
    end

    it "is invalid with a blank #{field} field" do
      write_package do |package|
        package[field] = ""
      end

      subject.should have_error("Package requires a '#{field}' field")
    end
  end

  it "is invalid without a proper version number" do
    write_package do |package|
      package["version"] = "bad"
    end

    subject.should have_error("Malformed version number string bad")
  end

  %w[lib test].each do |dir|
    it "is invalid without a #{dir} directory that exists" do
      write_package do |package|
        package["directories"][dir] = "nope"
      end

      subject.should have_error("'nope' specified for #{dir} directory, is not a directory")
    end

    it "is valid with a #{dir} directory that exists" do
      FileUtils.mkdir_p(home("somewhere", "else"))
      write_package do |package|
        package["directories"][dir] = "./somewhere/else"
      end

      subject.should be_valid
    end

    it "is invalid if #{dir} points to a file" do
      FileUtils.touch(home("somefile"))
      write_package do |package|
        package["directories"][dir] = "./somefile"
      end

      subject.should have_error("'./somefile' specified for #{dir} directory, is not a directory")
    end
  end
end
