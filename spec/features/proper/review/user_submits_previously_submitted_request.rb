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

require 'rails_helper'

RSpec.describe 'User submits a previously submitted request', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    Delayed::Worker.delay_jobs = false
  end

  after :each do
    Delayed::Worker.delay_jobs = true
  end

  before :each do
    org       = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service   = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1, one_time_fee: true)
    @protocol = create(:study_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, status: 'draft', protocol: @protocol, submitted_at: Date.today - 1.month)
    @ssr      = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'draft', submitted_at: Date.today - 1.month)
                create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
  end

  context 'and selects SSRs to submit' do
    scenario 'and sees the submitted SSRs' do
      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link I18n.t('proper.navigation.bottom.submit')
      wait_for_javascript_to_finish

      click_button I18n.t('actions.submit')
      wait_for_javascript_to_finish

      expect(@ssr.reload.status).to eq('submitted')
    end
  end

  context 'system satisfaction survey enabled' do
    stub_config('system_satisfaction_survey', true)

    before :each do
      create(:system_survey, :with_question, access_code: 'system-satisfaction-survey', title: 'System Satisfaction Survey', active: true)

      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link I18n.t('proper.navigation.bottom.submit')
      wait_for_javascript_to_finish
    end

    context 'user takes the survey' do
      scenario 'should show the SSR submission modal' do
        confirm_swal
        wait_for_javascript_to_finish

        fill_in 'response_question_responses_attributes_0_content', with: 'My answer is no'
        click_button I18n.t('actions.submit')
        wait_for_javascript_to_finish

        expect(page).to have_selector('#submitSSRsForm')
      end

      context 'user closes the modal without finishing' do
        scenario 'should show the SSR submission modal' do
          confirm_swal
          wait_for_javascript_to_finish

          fill_in 'response_question_responses_attributes_0_content', with: 'My answer is no'
          click_button I18n.t('actions.close')
          wait_for_javascript_to_finish

          expect(page).to have_selector('#submitSSRsForm')
        end
      end
    end

    context 'use closes the survey alert' do
      scenario 'should show the SSR submission modal' do
        cancel_swal
        wait_for_javascript_to_finish

        expect(page).to have_selector('#submitSSRsForm')
      end
    end
  end
end
