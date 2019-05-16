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

RSpec.describe 'User takes system satisfaction survey from Step 4', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true)
                  create(:pricing_setup, organization: program)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program)
    @protocol   = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr         = create(:service_request_without_validations, status: 'draft', protocol: @protocol)
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                  create(:arm, protocol: @protocol)
  end

  context 'but system is not using system satisfaction survey' do
    before :each do
      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish
    end

    context 'by clicking Get a Cost Estimate' do
      scenario 'and is taken directly to Obtain Research Pricing' do
        click_link 'Get a Cost Estimate'
        wait_for_page(obtain_research_pricing_service_request_path)
        expect(current_path).to eq(obtain_research_pricing_service_request_path)
      end
    end

    context 'by clicking Submit Request' do
      scenario 'and is taken directly to Confirmation' do
        click_link 'Submit Request'
        wait_for_javascript_to_finish
        wait_for_page(confirmation_service_request_path)
        expect(current_path).to eq(confirmation_service_request_path)
      end
    end
  end

  context 'and system is using system satisfaction survey' do
    stub_config("system_satisfaction_survey", true)
    
    before :each do
      @survey = create(:system_survey, access_code: 'system-satisfaction-survey', title: 'System Satisfaction Survey', active: true)

      visit review_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish
    end

    context 'by clicking Get a Cost Estimate' do
      before :each do
        click_link 'Get a Cost Estimate'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the survey prompt modal' do
        expect(page).to have_selector(".modal-title", text: "System Satisfaction Survey", visible: true)
      end

      context 'and closes the modal' do
        scenario 'and is redirected to Obtain Research Pricing' do
          find('#modal_place .no-button').click
          wait_for_javascript_to_finish
          wait_for_page(obtain_research_pricing_service_request_path)
          expect(current_path).to eq(obtain_research_pricing_service_request_path)
        end
      end

      context 'and clicks yes' do
        before :each do
          find('#modal_place .yes-button').click
          wait_for_javascript_to_finish
        end

        scenario 'and sees the survey' do
          expect(page).to have_selector('#survey-response', visible: true)
        end

        context 'and fills out and submits the survey' do
          before :each do
            find('#modal_place input[type="submit"]').click
            wait_for_javascript_to_finish
          end

          scenario 'and a response is recorded' do
            expect(@survey.responses.count).to eq(1)
          end

          scenario 'and is redirected to Obtain Research Pricing' do
            wait_for_page(obtain_research_pricing_service_request_path)
            expect(current_path).to eq(obtain_research_pricing_service_request_path)
          end
        end
      end
    end

    context 'By clicking Submit Request' do
      before :each do
        click_link 'Submit Request'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the survey prompt modal' do
        expect(page).to have_selector(".modal-title", text: "System Satisfaction Survey", visible: true)
      end

      context 'and closes the modal' do
        scenario 'and is redirected to Confirmation ' do
          find('#modal_place .no-button').click
          wait_for_javascript_to_finish
          wait_for_page(confirmation_service_request_path)
          expect(current_path).to eq(confirmation_service_request_path)
        end
      end

      context 'and clicks yes' do
        before :each do
          find('#modal_place .yes-button').click
          wait_for_javascript_to_finish
        end

        scenario 'and sees the survey' do
          expect(page).to have_selector('#survey-response', visible: true)
        end

        context 'and fills out and submits the survey' do
          before :each do
            find('#modal_place input[type="submit"]').click
            wait_for_javascript_to_finish
          end

          scenario 'and a response is recorded' do
            expect(@survey.responses.count).to eq(1)
          end

          scenario 'and is redirected to Confirmation' do
            wait_for_page(confirmation_service_request_path)
            expect(current_path).to eq(confirmation_service_request_path)
          end
        end
      end
    end
  end
end
