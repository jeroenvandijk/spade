RSpec::Matchers.define :be_fetched do
  include SpecHelpers
  match do |name|
    File.exist?(spade_dir("cache", "#{name}.gem")) == true
  end
end

RSpec::Matchers.define :be_unpacked do
  match do |name|
    File.directory?(spade_dir("gems", name)) == true
  end
end

# Make sure matchers can get to the path helpers
class RSpec::Matchers::Matcher
  include SpecHelpers
end
