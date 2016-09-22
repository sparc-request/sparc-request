# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.describe SurveyNotification do

  let(:identity)      { create(:identity, email: 'nobody@nowhere.com') }
  let(:survey)        { create(:survey,
                                title: "System Satisfaction survey",
                                description: nil,
                                access_code: "system-satisfaction-survey",
                                reference_identifier: nil,
                                data_export_identifier: nil,
                                common_namespace: nil,
                                common_identifier: nil, active_at: nil,
                                inactive_at: nil, css_url: nil,
                                custom_class: nil,
                                created_at: "2013-07-02 14:40:23",
                                updated_at: "2013-07-02 14:40:23",
                                display_order: 0, api_id: "4137bedf-40db-43e9-a411-932a5f6d77b7",
                                survey_version: 0) }
  let(:response_set)  { mock_model(ResponseSet, user_id: identity.id, survey_id: survey.id, access_code: 'abc123', survey: survey) }

  describe 'system satisfaction survey' do

    let(:mail) { SurveyNotification.system_satisfaction_survey(response_set) }

    #ensure that the subject is correct
    it 'renders the subject' do
      expect(mail).to have_subject("[Test - EMAIL TO catesa@musc.edu AND CC TO amcates@gmail.com, catesa@musc.edu] System satisfaction survey completed in SPARCRequest")
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      expect(mail).to deliver_from('nobody@nowhere.com') # set in application.yml as the default_mail_to
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      expect(mail).to deliver_to(DEFAULT_MAIL_TO)
    end

    #ensure that the e-mail body is correct
    it 'contains survey name' do
      expect(mail).to have_body_text("#{identity.display_name}\r\nhas completed a system satisfaction survey.\r\nResults can be found\r\n<a href=\"http://localhost:0/surveys/system-satisfaction-survey/abc123\">here</a>\r\n")
    end
  end

  describe 'service satisfaction survey' do
    include ApplicationHelper
    let(:institution) { create(:institution) }
    let(:provider) { create(:provider, parent_id: institution.id) }
    let(:program) { create(:program, parent_id: provider.id) }
    let(:core)    { create(:core, parent_id: program.id) }
    let(:ssr)     { create(:sub_service_request, organization_id: core.id) }
    let(:mail)    { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'renders the subject' do
      expect(mail).to have_subject("[Test - EMAIL TO nobody@nowhere.com] SPARCRequest Survey Notification")
    end

    #ensure that the receiver is correct
    it 'renders the receiver email' do
      expect(mail).to deliver_to(DEFAULT_MAIL_TO)
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      expect(mail).to deliver_from('no-reply@musc.edu')
    end

    #ensure that the e-mail body is correct
    it 'contains survey name' do
      expect(mail).to have_body_text("Dear #{identity.full_name},\r\n<br>\r\n<br>\r\nThank you for requesting services from\r\n#{ssr_institution(institution)} - #{ssr_provider(provider)} - #{ssr_program_core(core)}.\r\nThe service(s) you requested have now been completed.\r\n<br>\r\nPlease click on the link(s) below to complete the following survey(s) regarding the service(s) you received. Your feedback is important and appreciated!\r\n<br>\r\n<br>\r\n<ul></ul>\r\n<li><a href=\"http://localhost:0/direct_link_to/system-satisfaction-survey?ssr_id=#{ssr.id}&amp;survey_version=0\">System Satisfaction survey</a></li>\r\n")
    end
  end
end
