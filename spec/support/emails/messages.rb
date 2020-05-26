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

module EmailHelpers
  # Email messages based on the action (status:  submitted, ***more to come)

  #### REQUEST AMENDMENT MESSAGE ####
  def request_amendment_intro(mail_response)
    # Expected message:
    # 'Services have been added or deleted in SPARCRequest and is awaiting your review in SPARCDashboard.'
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'Services have been added or deleted in SPARCRequest and is awaiting your review in']")
    expect(mail_response).to have_xpath "//p//a[@href='/dashboard/protocols/#{@service_request.protocol.id}'][text()= 'SPARCDashboard.']/@href"
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'A list of requested services is attached.']")
    expect(mail_response).to have_xpath("//p[.='Please contact #{Setting.get_value('contact_us_mail_to')} or call (843) 792-8300 for technical assistance or contact the service provider directly for questions related to your service request.']")
  end

  #### DELETE ALL SERVICES MESSAGE ####
  def deleted_all_services_intro_for_service_providers(mail_response)
    # Expected message:
    # 'All services have been deleted in SPARCRequest for the Study
    # below to which you have been granted access.'
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'All services have been deleted in SPARCRequest for the #{@service_request.protocol.type} below to which you have been granted access.']")
    expect(mail_response).not_to have_xpath("//p[normalize-space(text()) = 'A list of requested services is attached.']")
    expect(@mail).to have_xpath("//p[.='Please contact #{Setting.get_value('contact_us_mail_to')} or call (843) 792-8300 for technical assistance or contact the service provider directly for questions related to your service request.']")
  end
  #### SUBMITTED MESSAGE METHODS ####
  def submitted_service_provider_and_admin_message
    # Expected message:
    # 'A request has been submitted to start services in
    # SPARCRequest and is awaiting your review in SPARCDashboard.'
    expect(@mail).to have_text('A request has been submitted to start services in SPARCRequest and is awaiting your review in SPARCDashboard.')
    expect(@mail).to have_xpath "//a[@href='/dashboard/protocols/#{@service_request.protocol.id}'][text()= 'SPARCDashboard']/@href"
  end

  def submitted_general_users_message
    # Expected user message:
    # "A request has been submitted to start services in
    # SPARCRequest. Visit SPARCDashboard to view the status or
    # make any updates to your request."
    expect(@mail.body.parts.first.body).to have_text("A request has been submitted to start services in SPARCRequest. Visit SPARCDashboard to view the status or make any updates to your request.")
    expect(@mail.body.parts.first.body).to have_xpath "//p//a[@href='/dashboard/protocols/#{@service_request.protocol.id}'][text()= 'SPARCDashboard']/@href"
  end
  #### END SUBMITTED MESSAGE METHODS ####


  #### REUSABLE METHODS ####
  def service_provider_and_admin_link(mail_response)
    expect(mail_response).to have_xpath "//p//a[@href='/dashboard/protocols/#{@service_request.protocol.id}'][text()= 'Administrators/Service Providers, Click Here']/@href"
  end

  def message_conclusion(mail_response)
    expect(mail_response).to have_xpath("//p[normalize-space(text()) = 'A list of requested services is attached.']")
    expect(mail_response).to have_xpath("//p[.='Please contact #{Setting.get_value('contact_us_mail_to')} or call (843) 792-8300 for technical assistance or contact the service provider directly for questions related to your service request.']")
  end

  def does_have_acknowledgments
    @service_request.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
      expect(@mail.body.parts.first.body).to have_xpath("//p[normalize-space(text()) = '#{ack}']")
    end
  end

  def does_not_have_acknowledgments(mail_response)
    @service_request.service_list.map{|k, v| v[:acks]}.flatten.uniq.each do |ack|
      expect(mail_response).not_to have_xpath("//p[normalize-space(text()) = '#{ack}']")
    end
  end
  #### END REUSABLE METHODS ####


  #### SUBMITTED ####
  def submitted_intro_for_service_providers_and_admin(mail_response)
    # Should have expected service provider message which is defined under submitted_service_provider_and_admin_message
    # Should have 'Administrators/Service Providers, Click Here' link
    # Should have standard message conclusion
    # Should NOT show acknowledgments
    submitted_service_provider_and_admin_message
    service_provider_and_admin_link(mail_response)
    message_conclusion(mail_response)
    does_not_have_acknowledgments(mail_response)
  end

  def submitted_intro_for_general_users
    # Should have expected user message which is defined under submitted_general_users_message
    # Should have standard message conclusion
    # Should show acknowledgments
    submitted_general_users_message
    message_conclusion(@mail.body.parts.first.body)
    does_have_acknowledgments
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end
