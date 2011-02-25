require "spec_helper"

describe "Spade Tests" do
  Dir["#{File.dirname(__FILE__)}/spade/*"].each do |path|
    run_core_tests(path)
  end
end
