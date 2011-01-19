source :rubygems

gem "eventmachine", "0.12.10"
gem "highline",     "1.6.1"
gem "json_pure",    "1.4.6"
gem "rack",         "1.2.1"
gem "thor",         "0.14.3"

platforms :mri_18, :mri_19 do
  gem "therubyracer", "0.8.0"
end

group :development do
  gem "rspec"

  platforms :mri_18 do
    gem "system_timer"
  end
end
