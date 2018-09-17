# Copyright © 2011-2018 MUSC Foundation for Research Development
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

  let(:identity)  { create(:identity, email: 'nobody@nowhere.com') }
  let(:org)       { create(:organization) }
  let(:ssr)       { create(:sub_service_request_without_validations, organization: org) }

  describe 'system satisfaction survey' do
    let(:survey)    { create(:system_survey, title: "System Satisfaction survey", access_code: "system-satisfaction-survey") }
    let(:response)  { create(:response, identity: identity, survey: survey, respondable: ssr) }
    let(:mail)      { SurveyNotification.system_satisfaction_survey(response) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("System Satisfaction Survey Completed in SPARCRequest")
    end

    #ensure that the receiver is correct
    it 'should render the receiver email' do
      expect(mail).to deliver_from(identity.email)
    end

    #ensure that the sender is correct
    it 'should render the sender email' do
      expect(mail).to deliver_to(Setting.get_value("admin_mail_to"))
    end

    #ensure that the e-mail contains a link to the survey
    it 'should contain the survey link' do
      survey_link_path = "surveyor/responses/#{response.id}"
      expect(mail.body.include?(survey_link_path)).to eq(true)
    end

    it 'should not contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("#sctr-grant-citation")).to eq(false)
    end
  end

  describe 'service system satisfaction survey' do
    let(:survey)    { create(:system_survey, title: "System Satisfaction survey", access_code: "system-satisfaction-survey") }
    let(:mail)      { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("SPARCRequest Survey Notification (Request #{ssr.display_id})")
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
      expect(["/surveyor/responses/", "/edit.html"].all? { |s| mail.body.include?(s) }).to eq(true)
    end

    it 'should not contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("#sctr-grant-citation")).to eq(false)
    end
  end

  describe 'SCTR Customer Satisfaction Survey' do
    let(:survey)    { create(:system_survey, title: "SCTR Customer Satisfaction survey", access_code: "sctr-customer-satisfaction-survey") }
    let(:mail)      { SurveyNotification.service_survey([survey], identity, ssr) }

    #ensure that the subject is correct
    it 'should render the subject' do
      expect(mail).to have_subject("SPARCRequest Survey Notification (Request #{ssr.display_id})")
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
      expect(["/surveyor/responses/", "/edit.html"].all? { |s| mail.body.include?(s) }).to eq(true)
    end

    it 'should contain the SCTR grant citation paragraph' do
      expect(mail.body.include?("id='sctr-grant-citation'")).to eq(true)
    end
  end
end
