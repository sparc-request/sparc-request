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

RSpec.describe 'User edits survey fields', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("site_admins", ["jug2"])

  context 'surveys' do
    before :each do
      @survey = create(:system_survey, title: 'Survey 1')
    end

    scenario 'and sees updated title' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@survey.id}-title", with: 'Survey Me'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@survey.reload.title).to eq('Survey Me')
    end

    scenario 'and sees updated description' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@survey.id}-description", with: 'A survey is a form for receiving information from users'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@survey.reload.description).to eq('A survey is a form for receiving information from users')
    end

    scenario 'and sees updated access code' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@survey.id}-access_code", with: 'access-denied'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@survey.reload.access_code).to eq('access-denied')
    end

    context 'and changes access_code to an already-used access code' do
      scenario 'and sees updated version' do
        create(:system_survey, title: 'Survey 2', access_code: 'access-denied', version: 1)
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        first('.bootstrap-select .survey-actions + .dropdown-toggle').click
        within '.dropdown-menu.open' do
          find('a', text: /Edit/).click
        end
        wait_for_javascript_to_finish

        fill_in "survey-#{@survey.id}-access_code", with: 'access-denied'
        find('.modal-title').click
        wait_for_javascript_to_finish

        expect(@survey.reload.version).to eq(2)
      end
    end

    scenario 'and sees updated version' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@survey.id}-version", with: '9000'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@survey.reload.version).to eq(9000)
    end
  end

  context 'forms' do
    before :each do
      @org = create(:institution)
      create(:super_user, organization: @org, identity: jug2)
      @form = create(:form, surveyable: @org)
    end

    scenario 'and sees updated title' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@form.id}-title", with: 'Form an Opinion'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@form.reload.title).to eq('Form an Opinion')
    end

    scenario 'and sees updated description' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@form.id}-description", with: 'Forms allow providers to get information about their services'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@form.reload.description).to eq('Forms allow providers to get information about their services')
    end

    scenario 'and sees updated access code' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@form.id}-access_code", with: 'access-denied'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@form.reload.access_code).to eq('access-denied')
    end

    scenario 'and sees updated version' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@form.id}-version", with: '9000'
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@form.reload.version).to eq(9000)
    end

    scenario 'and sees updated association' do
      service = create(:service, organization: @org, name: 'Helpful Service for all Your Service Needs', pricing_map_count: 1)

      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in "survey-#{@form.id}-surveyable", with: "Helpful"
      wait_for_javascript_to_finish

      expect(page).to have_selector('.tt-suggestion', text: service.name)

      first('.tt-suggestion').click
      wait_for_javascript_to_finish

      expect(@form.reload.surveyable).to eq(service)
    end
  end
end
