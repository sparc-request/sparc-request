# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.feature "User wants to create a Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_services

  before :each do
    visit '/'
    click_link 'South Carolina Clinical and Translational Institute (SCTR)'
    wait_for_javascript_to_finish
    click_link 'Office of Biomedical Informatics'
    wait_for_javascript_to_finish
    click_button 'Add', match: :first
    wait_for_javascript_to_finish
    click_button 'Yes'
    wait_for_javascript_to_finish
    find('.submit-request-button').click
    click_link 'New Research Study'
    wait_for_javascript_to_finish
  end

  #TODO: Add Authorized Users Specs
  context 'and clicks the New Study button' do
    scenario 'and sees the Protocol Information form' do
      page.find '#new_study'
    end

    scenario 'and sees the cancel button' do
      expect(page).to have_link 'Cancel'
    end

    scenario 'and sees the continue button' do
      expect(page).to have_link 'Continue'
    end

    context 'and submits the form without filling out required fields' do
      scenario 'and sees some errors' do
        click_link 'Continue'
        page.find '#errorExplanation'
      end
    end

    context 'funding sources' do
      before :each do
        fill_in 'study_short_title', with: 'title'
        fill_in 'study_title', with: 'title'
        choose 'study_has_cofc_false'
        fill_in 'study_sponsor_name', with: 'test'
      end

      scenario 'submits the form without selecting a funding source' do
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content "Funding status can't be blank"
      end

      scenario 'submits the form without selecting a potential source' do
        select 'Funded', from: 'study_funding_status'
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content 'Funding source You must select a funding source'
      end
    end

    context 'and submits the form after filling out required fields' do
      before :each do
        fill_in 'study_short_title', with: 'title'
        fill_in 'study_title', with: 'title'
        choose 'study_has_cofc_false'
        fill_in 'study_sponsor_name', with: 'test'
        select 'Funded', from: 'study_funding_status'
        select 'College Department', from: 'study_funding_source'
        click_link 'Continue'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the Authorized Users page' do
        expect(page).to have_content 'Add Users'
      end

      scenario 'and sees the go back button' do
        expect(page).to have_link 'Go Back'
      end

      scenario 'and sees the save and continue button' do
        expect(page).to have_link 'Save & Continue'
      end
    end
  end
end
