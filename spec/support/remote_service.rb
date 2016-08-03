# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
RSpec.configure do |config|

  config.before(:each) do
    stub_request(:post, /#{REMOTE_SERVICE_NOTIFIER_HOST}/).to_return(status: 201)
  end

  config.before(:each, remote_service: :unavailable) do
    stub_request(:post, /#{REMOTE_SERVICE_NOTIFIER_HOST}/).to_return(status: 500)
  end
end
