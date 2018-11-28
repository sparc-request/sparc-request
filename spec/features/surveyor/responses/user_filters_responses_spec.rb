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

RSpec.describe 'User filters responses', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config('site_admins', ['jug2'])

  before :each do
    @organization    = create(:organization)
    @super_user      = create(:super_user, identity: jug2, organization: @organization)
    @form            = create(:form, title: 'Formal Form', surveyable: @organization, active: true)
    @survey          = create(:system_survey, title: 'Serviceable Survey', active: true)
    @form_response   = create(:response, survey: @form)
    @survey_response = create(:response, survey: @survey)

    visit surveyor_responses_path
    wait_for_javascript_to_finish
  end

  describe 'type filter' do
    before :each do
      form_response   = create(:response, survey: @form)
      survey_response = create(:response, survey: @survey)
                        create(:question_response, response: form_response)
                        create(:question_response, response: survey_response)
    end

    context 'User filters Forms' do
      scenario 'and sees only Forms' do
        bootstrap_select '#filterrific_of_type', Form.name
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @form.title)
        expect(page).to have_no_selector('td', text: @survey.title)
      end
    end

    context 'User filters Surveys' do
      scenario 'and sees only Surveys' do
        bootstrap_select '#filterrific_of_type', Survey.name
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @survey.title)
        expect(page).to have_no_selector('td', text: @form.title)
      end
    end
  end

  describe 'state filter' do
    before :each do
      @inactive_survey  = create(:system_survey, title: 'Hollywood Stars and Celebrities. Do they know things? What do they know? Let\'s find out', active: false)
      inactive_response = create(:response, survey: @inactive_survey)
      survey_response   = create(:response, survey: @survey)
                          create(:question_response, response: inactive_response)
                          create(:question_response, response: survey_response)

    end

    context 'user filters Active surveys' do
      scenario 'and sees responses for active surveys' do
        bootstrap_multiselect '#filterrific_with_state', [I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active]]
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @survey.title)
        expect(page).to have_no_selector('td', text: @inactive_survey.title)
      end
    end

    context 'user filter Inactive surveys' do
      scenario 'and sees responses for inactive surveys' do
        bootstrap_multiselect '#filterrific_with_state', [I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive]]
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @inactive_survey.title)
        expect(page).to have_no_selector('td', text: @survey.title)
      end
    end

    context 'user filters Active and Inactive surveys' do
      scenario 'and sees responses for all surveys' do
        bootstrap_multiselect '#filterrific_with_state', [I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active], I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive]]
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @inactive_survey.title)
        expect(page).to have_selector('td', text: @survey.title)
      end
    end
  end

  describe 'Survey/Form filter' do
    context 'user filters by Survey' do
      before :each do
        @other_survey   = create(:system_survey, title: 'Hollywood Stars and Celebrities. Do they know things? What do they know? Let\'s find out', active: true)
        survey_response = create(:response, survey: @survey)
        other_response  = create(:response, survey: @other_survey)
                          create(:question_response, response: survey_response)
                          create(:question_response, response: other_response)
      end

      scenario 'and sees responses for those Surveys' do
        find('#for-SystemSurvey select#filterrific_with_survey + .btn-group').click
        first('.dropdown-menu.open span.text', text: "Version #{@survey.version} (#{@survey.active ? I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active] : I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive]})").click
        find('body').click
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @survey.title)
        expect(page).to have_no_selector('td', text: @other_survey.title)
      end
    end

    context 'user filters by Form' do
      before :each do
        @other_form     = create(:form, title: 'Hollywood Stars and Celebrities. Do they know things? What do they know? Let\'s find out', active: true)
        form_response   = create(:response, survey: @form)
        other_response  = create(:response, survey: @other_form)
                          create(:question_response, response: form_response)
                          create(:question_response, response: other_response)
      end

      scenario 'and sees responses for those Forms' do
        bootstrap_select '#filterrific_of_type', 'Form'
        find('#for-Form select#filterrific_with_survey + .btn-group').click
        first('.dropdown-menu.open span.text', text: "Version #{@form.version} (#{@form.active ? I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active] : I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive]})").click
        find('body').click
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @form.title)
        expect(page).to have_no_selector('td', text: @other_form.title)
      end
    end
  end

  describe 'completion date' do
    before :each do
      @other_survey   = create(:system_survey, title: 'Hollywood Stars and Celebrities. Do they know things? What do they know? Let\'s find out', active: true)
      survey_response = create(:response, survey: @survey, updated_at: Time.now - 5.days)
      other_response  = create(:response, survey: @other_survey, updated_at: Time.now + 5.days)
                        create(:question_response, response: survey_response)
                        create(:question_response, response: other_response)
    end

    describe 'from filter' do
      scenario 'and sees responses completed after the date' do
        find('#filterrific_start_date').click
        find('body').click
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish


        expect(page).to have_selector('td', text: @other_survey.title)
        expect(page).to have_no_selector('td', text: @survey.title)
      end
    end

    describe 'to filter' do
      scenario 'and sees responses completed before the date' do
        find('#filterrific_end_date').click
        find('body').click
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @survey.title)
        expect(page).to have_no_selector('td', text: @other_survey.title)
      end
    end
  end

  describe 'incomplete filter' do
    before :each do
      @other_survey   = create(:system_survey, title: 'Hollywood Stars and Celebrities. Do they know things? What do they know? Let\'s find out', active: true)
      survey_response = create(:response, survey: @survey)
      other_response  = create(:response, survey: @other_survey)
                        create(:question_response, response: survey_response)
                        # other_response is incomplete
    end

    context 'user filters only completed responses' do
      scenario 'and sees only completed responses' do
        click_button I18n.t(:actions)[:filter]
        wait_for_javascript_to_finish

        expect(page).to have_selector('td', text: @survey.title)
        expect(page).to have_no_selector('td', text: @other_survey.title)
      end
    end

    context 'user filters including incomplete responses' do
      context 'for surveys' do
        scenario 'and sees both complete and incomplete responses' do
          find('#filterrific_include_incomplete').click
          click_button I18n.t(:actions)[:filter]
          wait_for_javascript_to_finish

          expect(page).to have_selector('td', text: @survey.title)
          expect(page).to have_selector('td', text: @other_survey.title)
        end
      end

      context 'for forms' do
        scenario 'and sees both complete and incomplete responses' do
          @other_form     = create(:form, surveyable: @organization, title: 'Formula One', active: true)
          other_response  = create(:response, survey: @other_form)
          ssr             = create(:sub_service_request, organization: @organization)

          bootstrap_select '#filterrific_of_type', Form.name
          find('#filterrific_include_incomplete').click
          click_button I18n.t(:actions)[:filter]
          wait_for_javascript_to_finish

          expect(page).to have_selector('td', text: @form.title)
          expect(page).to have_selector('td', text: @other_form.title)
        end
      end
    end
  end
end
