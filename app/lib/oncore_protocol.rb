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

  attr_accessor :auth, :protocol_no, :protocol_id, :title, :short_title, :library, :department, :organizational_unit, :protocol_type, :institution, :primary_pi, :primary_pi_role

  def initialize(study)
    # Use default values for fields that do not correlate to SPARC values
    self.protocol_no         = "STUDY#{study.id}"
    self.title               = study.title
    self.short_title         = study.short_title
    self.library             = Setting.get_value("oncore_default_library")
    self.department          = (study.primary_pi.professional_organization.try(:department_name) || Setting.get_value("oncore_default_department")).upcase
    self.organizational_unit = Setting.get_value("oncore_default_organizational_unit")
    self.protocol_type       = Setting.get_value("oncore_default_protocol_type")

    self.institution         = Setting.get_value("oncore_default_institution")
    self.primary_pi          = study.primary_pi
    self.primary_pi_role     = Setting.get_value("oncore_default_pi_role")
  end

  def create_oncore_protocol
    auth_response = authenticate
    if auth_response.success?
      push_base_response = push_base_oncore_protocol
      return push_base_response if !push_base_response.success?

      id_search_response = oncore_protocol_id_search
      return id_search_response if !id_search_response.success?

      add_institution_response = add_insitution
      return add_institution_response if !add_institution_response.success?

      primary_pi_response = add_primary_pi

      return primary_pi_response
    else
      return auth_response
    end
  end

  def push_base_oncore_protocol
    response = self.class.post('/oncore-api/rest/protocols',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => self.auth
                              },
                              body: {
                                protocolNo: self.protocol_no,
                                title: self.title,
                                shortTitle: self.short_title,
                                library: self.library,
                                department: self.department,
                                organizationalUnit: self.organizational_unit,
                                protocolType: self.protocol_type
                              }.to_json)
    log_request_and_response(response)
    return response
  end

  # Get the OnCore protocolId, like SPARC's ids but specific to OnCore
  # protocolId is required field in most POST requests related to a protocol.
  def oncore_protocol_id_search
    response = self.class.get('/oncore-api/rest/protocols',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => self.auth
                              },
                              query: {
                                protocolNo: self.protocol_no
                              })
    log_request_and_response(response)
    self.protocol_id = response.success? ? response.first['protocolId'] : nil
    return response
  end

  def add_insitution
    response = self.class.post('/oncore-api/rest/protocolInstitutions',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => self.auth
                              },
                              body: {
                                protocolId: self.protocol_id,
                                institution: self.institution
                              }.to_json)
    log_request_and_response(response)
    return response
  end

  def add_primary_pi
    contact_response = response = self.class.get('/oncore-api/rest/contacts',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => self.auth
                              },
                              query: {
                                email: self.primary_pi.email,
                                firstName: self.primary_pi.first_name,
                                lastName: self.primary_pi.last_name
                              })
    log_request_and_response(contact_response)
    return contact_response if !contact_response.success?

    contact_id = response.first['contactId']

    staff_response = self.class.post('/oncore-api/rest/protocolStaff',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => self.auth
                              },
                              body: {
                                protocolId: self.protocol_id,
                                contactId: contact_id,
                                role: self.primary_pi_role
                              }.to_json)
    log_request_and_response(staff_response)
    return staff_response
  end

  def authenticate
    response = self.class.post('/forte-platform-web/api/oauth/token',
                              headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
                              body: {
                                client_id: ENV.fetch('oncore_client_id'),
                                client_secret: ENV.fetch('oncore_client_secret'),
                                grant_type: 'client_credentials'
                              }.to_json)

    if response.success?
      self.auth = "Bearer " + JSON.parse(response.body)['access_token']
    end

    return response
  end

  # Log requests and responses without exposing any authentication information in headers
  def log_request_and_response(response)
    request = response.request

    # Use the OnCore logger, it's easier than digging through the Rails logger
    logfile = File.join(Rails.root, '/log/', "OnCore-#{Rails.env}.log")
    logger = ActiveSupport::Logger.new(logfile)

    logger.info "\n----------------------------------------------------------------------------------"
    logger.info "OnCore REST request ---------- Timestamp: #{DateTime.now.to_formatted_s(:long)}"
    logger.info "URI: " + request.uri.to_s
    logger.info "HTTP method: " + request.http_method.to_s
    logger.info "Request Body:\n" + request.raw_body.to_s
    logger.info "Response:\n" + response.to_s
  end
end