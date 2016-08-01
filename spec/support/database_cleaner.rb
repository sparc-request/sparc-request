# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner[:active_record, connection: :test].clean_with :truncation
  end

  config.before(:each) do |example|
    DatabaseCleaner[:active_record, connection: :test].strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
