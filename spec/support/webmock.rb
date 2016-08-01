# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|

  config.before(:each) do
    stub_request(:get, "https://www.sparcrequestblog.com/").
     to_return(status: 200, body: "")
  end
end
