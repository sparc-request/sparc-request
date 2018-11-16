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

RSpec.describe 'User edits section fields', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("site_admins", ["jug2"])

  context 'surveys' do
    before :each do
      @survey = create(:system_survey)
      @section = create(:section, survey: @survey)
    end

    scenario 'and sees updated title' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in("section-#{@section.id}-title", with: 'This is a Terrible Section')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@section.reload.title).to eq('This is a Terrible Section')
    end

    scenario 'and sees updated description' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in("section-#{@section.id}-description", with: 'How can I describe such a terrible section?')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@section.reload.description).to eq('How can I describe such a terrible section?')
    end

    context 'and adds a section' do
      scenario 'and sees the new section' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_select '.survey-actions', /Edit/
        wait_for_javascript_to_finish

        find('.add-section').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.section', count: 2)
        expect(@survey.sections.count).to eq(2)
      end
    end

    context 'and removes a section' do
      scenario 'and does not see the deleted section' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_select '.survey-actions', /Edit/
        wait_for_javascript_to_finish

        find('.delete-section').click
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.section')
        expect(@survey.sections.count).to eq(0)
      end
    end
  end

  context 'forms' do
    before :each do
      org = create(:institution)
      create(:super_user, organization: org, identity: jug2)
      @form = create(:form, surveyable: org)
      @section = create(:section, survey: @form)
    end

    scenario 'and sees updated title' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in("section-#{@section.id}-title", with: 'This is a Terrible Section')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@section.reload.title).to eq('This is a Terrible Section')
    end

    scenario 'and sees updated description' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Edit/
      wait_for_javascript_to_finish

      fill_in("section-#{@section.id}-description", with: 'How can I describe such a terrible section?')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@section.reload.description).to eq('How can I describe such a terrible section?')
    end

    context 'and adds a section' do
      scenario 'and sees the new section' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_select '.survey-actions', /Edit/
        wait_for_javascript_to_finish

        find('.add-section').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.section', count: 2)
        expect(@form.sections.count).to eq(2)
      end
    end

    context 'and removes a section' do
      scenario 'and does not see the deleted section' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_select '.survey-actions', /Edit/
        wait_for_javascript_to_finish

        find('.delete-section').click
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.section')
        expect(@form.sections.count).to eq(0)
      end
    end
  end
end
