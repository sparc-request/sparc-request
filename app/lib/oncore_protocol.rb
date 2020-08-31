# Copyright © 2011-2020 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class OncoreProtocol
  include HTTParty
  base_uri Setting.get_value('oncore_api')

  attr_accessor :auth, :protocol_no, :title, :short_title, :library, :department, :organizational_unit, :protocol_type

  def initialize(study)
    # Use default values for fields that do not correlate to SPARC values
    self.protocol_no         = "STUDY#{study.id}"
    self.title               = study.title
    self.short_title         = study.short_title
    self.library             = Setting.get_value("oncore_default_library")
    self.department          = study.primary_pi.professional_organization.try(:department) || Setting.get_value("oncore_default_department")
    self.organizational_unit = Setting.get_value("oncore_default_organizational_unit")
    self.protocol_type       = Setting.get_value("oncore_default_protocol_type")
  end

  def create_oncore_protocol
    auth_response = self.authenticate
    if auth_response.success?
    # Assumes that the push will fail if it already exists in OnCore, need to confirm
      response = self.class.post('/oncore-api/rest/protocols.json',
                                headers: {
                                  'Content-Type' => 'application/json',
                                  'Authorization' => self.auth
                                },
                                body: {
                                  protocolNo: self.protocol_no,
                                  title: self.title,
                                  short_title: self.short_title,
                                  library: self.library,
                                  department: self.department,
                                  organizationalUnit: self.organizational_unit,
                                  protocolType: self.protocol_type
                                }.to_json)
    else
      return auth_response
    end
  end

  def authenticate
    response = self.class.post('/forte-platform-web/api/oauth/token.json',
                              headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
                              body: {
                                client_id: ENV.fetch('oncore_client_id'),
                                client_secret: ENV.fetch('oncore_client_secret'),
                                grant_type: 'client_credentials'
                              }.to_json)
    if response.success?
      self.auth = "Bearer " + JSON.parse(response)['access_token']
    end

    return response
  end
end