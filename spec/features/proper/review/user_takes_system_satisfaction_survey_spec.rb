# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe 'User takes system satisfaction survey after reviewing their request', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service   = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1, one_time_fee: true)
    @protocol = create(:study_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, status: 'draft', protocol: @protocol)
    ssr       = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'draft')
                create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
  end

  context 'system satisfaction is turned off' do
    before :each do
      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish
    end

    context 'Get a Cost Estimate' do
      it 'should not offer a survey' do
        click_link I18n.t("proper.navigation.bottom.get_cost_estimate")
        wait_for_javascript_to_finish
        expect(page).to have_current_path(obtain_research_pricing_service_request_path(srid: @sr.id))
      end
    end

    context 'Submitting Request' do
      it 'should not offer a survey' do
        click_link I18n.t('proper.navigation.bottom.submit')
        wait_for_javascript_to_finish
        expect(page).to have_current_path(confirmation_service_request_path(srid: @sr.id))
      end
    end
  end

  context 'system satisfaction is turned on' do
    stub_config('system_satisfaction_survey', true)

    before :each do
      @survey = create(:system_survey, :with_question, access_code: 'system-satisfaction-survey', title: 'System Satisfaction Survey', active: true)

      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish
    end

    context 'Get a Cost Estimate' do
      before :each do
        click_link I18n.t("proper.navigation.bottom.get_cost_estimate")
        wait_for_javascript_to_finish
      end

      it 'should offer a survey' do
        confirm_swal
        fill_in 'response_question_responses_attributes_0_content', with: 'My answer is no'
        click_button I18n.t('actions.submit')
        wait_for_javascript_to_finish

        expect(@survey.responses.count).to eq(1)
        expect(jug2.responses.count).to eq(1)
        expect(page).to have_current_path(obtain_research_pricing_service_request_path(srid: @sr.id))
      end

      context 'user declines the survey' do
        it 'should go to Get a Cost Estimate' do
          cancel_swal
          wait_for_javascript_to_finish

          expect(page).to have_current_path(obtain_research_pricing_service_request_path(srid: @sr.id))
        end
      end
    end

    context 'Submitting Request' do
      before :each do
        click_link I18n.t('proper.navigation.bottom.submit')
        wait_for_javascript_to_finish
      end

      it 'should offer a survey' do
        confirm_swal
        fill_in 'response_question_responses_attributes_0_content', with: 'My answer is no'
        click_button I18n.t('actions.submit')
        wait_for_javascript_to_finish

        expect(@survey.responses.count).to eq(1)
        expect(jug2.responses.count).to eq(1)
        # expect(page).to have_current_path(confirmation_service_request_path(srid: @sr.id)) ##TODO: This causes random failures on Travis (page seems not to load)
      end

      context 'user declines the survey' do
        it' should go to Confirmation' do
          cancel_swal
          wait_for_javascript_to_finish

          expect(page).to have_current_path(confirmation_service_request_path(srid: @sr.id))
        end
      end
    end
  end
end
