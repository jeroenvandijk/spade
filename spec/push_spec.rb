require 'spec_helper'

describe 'pushing a spade' do
  it "requests username and password" do
    spade "push", "somefile"
    stdout.should contain_line("Enter your Spade credentials.")
  end
end
