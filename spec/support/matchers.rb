RSpec::Matchers.define :be_fetched do
  include SpecHelpers
  match do |name|
    File.exist?(home(".spade", "cache", "#{name}.gem")) == true
  end
end

RSpec::Matchers.define :be_unpacked do
  match do |name|
    File.directory?(home(".spade", "gems", name)) == true
  end
end

# Make sure matchers can get to the path helpers
class RSpec::Matchers::Matcher
  include SpecHelpers
end
