require 'spec_helper'

describe Spade::Credentials do
  def new_creds
    Spade::Credentials.new(Spade::Environment.new)
  end

  around do |example|
    cd(home)
    old_home    = ENV["HOME"]
    ENV["HOME"] = home.to_s
    example.call
    ENV["HOME"] = old_home
  end

  subject { new_creds }

  it "saves the api key and email" do
    subject.save("someone@example.com", "secrets")

    new_creds.api_key.should == "secrets"
    new_creds.email.should == "someone@example.com"
  end
end
