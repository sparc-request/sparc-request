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
  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming

  include HTTParty
  base_uri Setting.get_value('oncore_api')

  class OncorePushError < StandardError; end

  attr_accessor :auth,
                :protocol_no,
                :protocol_id,
                :title,
                :short_title,
                :library,
                :department,
                :organizational_unit,
                :protocol_type,
                :institution,
                :primary_pi,
                :primary_pi_contact_id,
                :primary_pi_role
  attr_reader   :errors

  def initialize(study)
    # Use default values for fields that do not correlate to SPARC values
    @protocol_no         = "STUDY#{study.id}"
    @title               = study.title
    @short_title         = "#{study.short_title} - #{study.title}"
    @library             = Setting.get_value("oncore_default_library")
    @department          = (study.primary_pi.professional_organization.try(:department_name) || Setting.get_value("oncore_default_department")).upcase
    @organizational_unit = Setting.get_value("oncore_default_organizational_unit")
    @protocol_type       = Setting.get_value("oncore_default_protocol_type")

    @institution         = Setting.get_value("oncore_default_institution")
    @primary_pi          = study.primary_pi
    @primary_pi_role     = Setting.get_value("oncore_default_pi_role")

    @errors = ActiveModel::Errors.new(self)
  end

  def create_oncore_protocol
    protocol_push_successful = false
    begin
      authenticate
      push_base_oncore_protocol
      oncore_protocol_id_search
      add_insitution

      protocol_push_successful = true

      get_primary_pi_contact_id
      add_primary_pi
    rescue OncorePushError
      # Don't need to do anything special if this is raised, errors are already assigned in HTTP call method
    end

    return protocol_push_successful
  end

  def push_base_oncore_protocol
    response = self.class.post('/oncore-api/rest/protocols',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => @auth
                              },
                              body: {
                                protocolNo: @protocol_no,
                                title: @title,
                                shortTitle: @short_title,
                                library: @library,
                                department: @department,
                                organizationalUnit: @organizational_unit,
                                protocolType: @protocol_type
                              }.to_json)

    log_request_and_response(response)
    if !response.success? && response['message'].try(:include?, ('already exists'))
      @errors.add(:base, :already_exists)
      raise OncorePushError
    elsif !response.success?
      @errors.add(:base, :post_protocols_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    end
  end

  # Get the OnCore protocolId, like SPARC's ids but specific to OnCore
  # protocolId is required field in most POST requests related to a protocol.
  def oncore_protocol_id_search
    response = self.class.get('/oncore-api/rest/protocols',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => @auth
                              },
                              query: {
                                protocolNo: @protocol_no
                              })

    log_request_and_response(response)
    unless response.success?
      @errors.add(:base, :get_protocols_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    end
    @protocol_id = response.first['protocolId']
  end

  def add_insitution
    response = self.class.post('/oncore-api/rest/protocolInstitutions',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => @auth
                              },
                              body: {
                                protocolId: @protocol_id,
                                institution: @institution
                              }.to_json)

    log_request_and_response(response)
    unless response.success?
      @errors.add(:base, :post_protocols_institutions_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    end
  end

  def get_primary_pi_contact_id
    response = self.class.get('/oncore-api/rest/contacts',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => @auth
                              },
                              query: {
                                email: @primary_pi.email,
                                firstName: @primary_pi.first_name,
                                lastName: @primary_pi.last_name
                              })

    log_request_and_response(response)
    if !response.success?
      @errors.add(:base, :get_contacts_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    elsif response.success? && response.empty?
      @errors.add(:base, :pi_not_in_oncore)
      raise OncorePushError
    end

    @primary_pi_contact_id = response.first['contactId']
  end

  def add_primary_pi
    response = self.class.post('/oncore-api/rest/protocolStaff',
                              headers: {
                                'Accept' => 'application/json',
                                'Content-Type' => 'application/json',
                                'Authorization' => @auth
                              },
                              body: {
                                protocolId: @protocol_id,
                                contactId: @primary_pi_contact_id,
                                role: @primary_pi_role
                              }.to_json)

    log_request_and_response(response)
    unless response.success?
      @errors.add(:base, :post_protocol_staff_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    end
  end

  def authenticate
    response = self.class.post('/forte-platform-web/api/oauth/token',
                              headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
                              body: {
                                client_id: ENV.fetch('oncore_client_id'),
                                client_secret: ENV.fetch('oncore_client_secret'),
                                grant_type: 'client_credentials'
                              }.to_json)

    unless response.success?
      @errors.add(:base, :auth_failed, message: "#{response.code}: #{response.message}")
      raise OncorePushError
    end
    @auth = "Bearer " + JSON.parse(response.body)['access_token']
  end

  # Methods needed for implementing ActiveModel::Errors
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  private

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