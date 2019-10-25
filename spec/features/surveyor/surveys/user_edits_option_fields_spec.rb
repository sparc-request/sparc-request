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

RSpec.describe 'User edits option fields', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("site_admins", ["jug2"])

  context 'surveys' do
    before :each do
      @survey = create(:system_survey)
      @section = create(:section, survey: @survey)
      @question = create(:question, section: @section, question_type: 'dropdown')
      @option = create(:option, question: @question)
    end

    scenario 'and sees updated content' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_dropdown("#surveyActions#{@survey.id}", /Edit/)
      wait_for_javascript_to_finish

      fill_in("option-#{@option.id}-content", with: 'This is a Terrible Option')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@option.reload.content).to eq('This is a Terrible Option')
    end

    context 'and adds and option' do
      scenario 'and sees a new option' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@survey.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.add-option').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.option', count: 2)
        expect(@question.options.count).to eq(2)
      end

      scenario 'and sees updated dependent selectpickers' do
        @question2 = create(:question, section: @section, is_dependent: true)

        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@survey.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.add-option').click
        wait_for_javascript_to_finish

        new_opt = Option.last

        find('.select-depender').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.select-depender .text', text: new_opt.content, visible: true)
      end
    end

    context 'and removes an option' do
      scenario 'and does not see the deleted option' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@survey.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.delete-option').click
        wait_for_javascript_to_finish
        confirm_swal
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.option')
        expect(@question.options.count).to eq(0)
      end

      scenario 'and sees updated dependent selectpickers' do
        @question2 = create(:question, section: @section, is_dependent: true)

        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@survey.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.delete-option').click
        wait_for_javascript_to_finish
        confirm_swal
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.select-depender .text', text: @option.content, visible: true)
      end
    end
  end

  context 'forms' do
    before :each do
      org = create(:institution)
      create(:super_user, organization: org, identity: jug2)
      @form = create(:form, surveyable: org)
      @section = create(:section, survey: @form)
      @question = create(:question, section: @section, question_type: 'dropdown')
      @option = create(:option, question: @question)
    end

    scenario 'and sees updated content' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_dropdown("#surveyActions#{@form.id}", /Edit/)
      wait_for_javascript_to_finish

      fill_in("option-#{@option.id}-content", with: 'This is a Terrible Option')
      find('.modal-title').click
      wait_for_javascript_to_finish

      expect(@option.reload.content).to eq('This is a Terrible Option')
    end

    context 'and adds and option' do
      scenario 'and sees a new option' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@form.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.add-option').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.option', count: 2)
        expect(@question.options.count).to eq(2)
      end

      scenario 'and sees updated dependent selectpickers' do
        @question2 = create(:question, section: @section, is_dependent: true)

        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@form.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.add-option').click
        wait_for_javascript_to_finish

        new_opt = Option.last

        find('.select-depender').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.select-depender .text', text: new_opt.content, visible: true)
      end
    end

    context 'and removes an option' do
      scenario 'and does not see the deleted option' do
        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@form.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.delete-option').click
        wait_for_javascript_to_finish
        confirm_swal
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.option')
        expect(@question.options.count).to eq(0)
      end

      scenario 'and sees updated dependent selectpickers' do
        @question2 = create(:question, section: @section, is_dependent: true)

        visit surveyor_surveys_path
        wait_for_javascript_to_finish

        bootstrap_dropdown("#surveyActions#{@form.id}", /Edit/)
        wait_for_javascript_to_finish

        find('.delete-option').click
        wait_for_javascript_to_finish
        confirm_swal
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('.select-depender .text', text: @option.content, visible: true)
      end
    end
  end
end
