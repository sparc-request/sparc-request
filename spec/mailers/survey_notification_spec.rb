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

  describe 'system satisfaction survey' do
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
    let(:mail) { SurveyNotification.system_satisfaction_survey(response_set) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("System satisfaction survey completed in SPARCRequest")
    end

    #ensure that the receiver is correct
    it 'should render the receiver email' do
      expect(mail).to deliver_from('nobody@nowhere.com') # set in application.yml as the default_mail_to
    end

    #ensure that the sender is correct
    it 'should render the sender email' do
      expect(mail).to deliver_to(ADMIN_MAIL_TO)
    end

    #ensure that the e-mail contains a link to the survey
    it 'should contain the survey link' do
      survey_link_path = "surveys/#{survey.access_code}/#{response_set.access_code}"
      expect(mail.body.include?(survey_link_path)).to eq(true)
    end

    it 'should not contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("#sctr-grant-citation")).to eq(false)
    end
  end

  describe 'service satisfaction survey' do
    include ApplicationHelper
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
    let(:institution)   { create(:institution) }
    let(:provider)      { create(:provider, parent_id: institution.id) }
    let(:program)       { create(:program, parent_id: provider.id) }
    let(:core)          { create(:core, parent_id: program.id) }
    let(:ssr)           { create(:sub_service_request, organization_id: core.id) }
    let(:mail)          { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("SPARCRequest Survey Notification")
    end

    #ensure that the receiver is correct
    it 'should render the receiver email' do
      expect(mail).to deliver_to(identity.email)
    end

    #ensure that the sender is correct
    it 'should render the sender email' do
      expect(mail).to deliver_from('no-reply@musc.edu')
    end

    #ensure that the e-mail contains a link to the survey
    it 'should contain the survey link' do
      survey_link_path = "direct_link_to/#{survey.access_code}?ssr_id=#{ssr.id}&amp;survey_version=#{survey.survey_version}"
      expect(mail.body.include?(survey_link_path)).to eq(true)
    end

    it 'should not contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("#sctr-grant-citation")).to eq(false)
    end
  end

  describe 'SCTR Customer Satisfaction Survey' do
    include ApplicationHelper
    let(:identity)      { create(:identity, email: 'nobody@nowhere.com') }
    let(:survey)        { create(:survey,
                                  title: "SCTR Customer Satisfaction Survey",
                                  description: nil,
                                  access_code: "sctr-customer-satisfaction-survey",
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
    let(:institution)   { create(:institution) }
    let(:provider)      { create(:provider, parent_id: institution.id) }
    let(:program)       { create(:program, parent_id: provider.id) }
    let(:core)          { create(:core, parent_id: program.id) }
    let(:ssr)           { create(:sub_service_request, organization_id: core.id) }
    let(:mail)          { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("SPARCRequest Survey Notification")
    end

    #ensure that the receiver is correct
    it 'should render the receiver email' do
      expect(mail).to deliver_to(identity.email)
    end

    #ensure that the sender is correct
    it 'should render the sender email' do
      expect(mail).to deliver_from('no-reply@musc.edu')
    end

    #ensure that the e-mail contains a link to the survey
    it 'should contain the survey link' do
      survey_link_path = "direct_link_to/#{survey.access_code}?ssr_id=#{ssr.id}&amp;survey_version=#{survey.survey_version}"
      expect(mail.body.include?(survey_link_path)).to eq(true)
    end

    it 'should contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("id='sctr-grant-citation'")).to eq(true)
    end
  end
end
