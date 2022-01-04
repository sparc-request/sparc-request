# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

WebMock.disable_net_connect!({
  allow_localhost: true,
  allow: ['chromedriver.storage.googleapis.com', %r{github}]
  })

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "https://sparcrequest.atlassian.net/wiki").
      to_return(status: 200, body: "")

    stub_request(:post, /#{Setting.get_value("remote_service_notifier_host")}/).
      to_return(status: 201)

    ##### OnCore Stubs #####
    stub_request(:get, /#{Regexp.quote(Setting.get_value("oncore_api"))}\/oncore-api\/rest\/protocols\?protocolNo=STUDY([0-9])+/).
      to_return(status: 200, body: '[{"protocolId" => 1111}]')

    stub_request(:get, /#{Regexp.quote(Setting.get_value("oncore_api"))}\/oncore-api\/rest\/contacts\?email=(.+)&firstName=(.+)&lastName=(.+)/).
      to_return(status: 200, body: '[{"contactId" => 2222}]')

    stub_request(:post, "#{Setting.get_value("oncore_api")}/oncore-api/rest/protocols").
      to_return(status: 201)

    stub_request(:post, "#{Setting.get_value("oncore_api")}/oncore-api/rest/protocolInstitutions").
      to_return(status: 201)

    stub_request(:post, "#{Setting.get_value("oncore_api")}/oncore-api/rest/protocolStaff").
      to_return(status: 201)

    stub_request(:post, "#{Setting.get_value("oncore_api")}/forte-platform-web/api/oauth/token").
      to_return(status: 200, body: { access_token: "some_token_value", expires_in: "300", token_type: "Bearer" }.to_json)
  end

  config.before(:each, oncore_protocol: :exists) do
    stub_request(:post, "#{Setting.get_value("oncore_api")}/oncore-api/rest/protocols").
      to_return(status: 400,
        body: { "message" => "Protocol with protocol no. 'STUDY1' already exists", "errorType" => "FieldValidationError", "field" => "protocolNo" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  config.before(:each, oncore_pi: :does_not_exist) do
    stub_request(:get, /#{Regexp.quote(Setting.get_value("oncore_api"))}\/oncore-api\/rest\/contacts\?email=(.+)&firstName=(.+)&lastName=(.+)/).
      to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })
  end

  config.before(:each, remote_service: :unavailable) do
    stub_request(:post, /#{Setting.get_value("remote_service_notifier_host")}/).
      to_return(status: 500)

    ##### OnCore Stubs #####
    stub_request(:post, "#{Setting.get_value("oncore_api")}/forte-platform-web/api/oauth/token").
      to_return(status: 500)
  end
end
