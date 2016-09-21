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

RSpec.feature 'User wants to create a Project', js: true do
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
    click_link 'New Project'
    wait_for_javascript_to_finish
  end
  context 'clicks the New Project button' do
    scenario 'and sees the Protocol Information form' do
      page.find '#new_project'
    end

    scenario 'and sees the cancel button' do
      expect(page).to have_link 'Cancel'
    end

    scenario 'and sees the continue button' do
      expect(page).to have_link 'Continue'
    end

    context 'funding sources' do
      before :each do
        fill_in 'project_short_title', with: 'title'
        fill_in 'project_title', with: 'title'
      end
      scenario 'submits the form without selecting a funding source' do
        select 'Funded', from: 'project_funding_status'
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content "Funding source You must select a funding source"
      end

      scenario 'and submits the form without selecting a potential funding source' do
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content "Funding status can't be blank"
      end
    end

    context 'and submits the form after filling out required fields' do
      before :each do
        fill_in 'project_short_title', with: 'title'
        fill_in 'project_title', with: 'title'
        select 'Funded', from: 'project_funding_status'
        select 'College Department', from: 'project_funding_source'
        click_link 'Continue'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the go back button' do
        expect(page).to have_link 'Go Back'
      end

      scenario 'and sees the save and continue button' do
        expect(page).to have_link 'Save & Continue'
      end

      scenario 'and sees the Project with correct information' do
        select 'Primary PI', from: 'project_role_role'
        click_button 'Add Authorized User'
        wait_for_javascript_to_finish
        click_link 'Save & Continue'
        wait_for_javascript_to_finish
        expect(page).to have_link 'Edit Project'
      end

      context 'and looks for an additional user' do
        before :each do
          select 'Primary PI', from: 'project_role_role'
          click_button 'Add Authorized User'
          wait_for_javascript_to_finish
          fill_autocomplete('user_search_term', with: 'bjk7')
          wait_for_javascript_to_finish
          page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
          select 'PD/PI', from: 'project_role_role'
        end

        scenario 'and sees the user information' do
          expect(page).to have_content "Brian Kelsey"
          expect(page).to have_content "kelsey@musc.edu"
        end

        scenario 'and adds the authorized user' do
          click_button 'Add Authorized User'
          wait_for_javascript_to_finish
          expect(page).not_to have_content('kelsey@musc.edu')
          click_link 'Save & Continue'
          expect(page).to have_link 'Edit Project'
        end
      end
    end
  end

end
