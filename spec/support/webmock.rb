WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|

  config.before(:each) do
    stub_request(:get, "http://www.sparcrequestblog.com/").
     to_return(status: 200, body: "")
  end
end
