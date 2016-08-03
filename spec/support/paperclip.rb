# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
