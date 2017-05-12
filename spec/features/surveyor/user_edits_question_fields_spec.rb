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

RSpec.describe 'User edits question fields', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    @survey = create(:survey)
    @section = create(:section, survey: @survey)
    @question = create(:question, section: @section)

    stub_const("SITE_ADMINS", ['jug2'])
  end

  scenario 'and sees updated title' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in('question-content', with: 'This is a Terrible Question')
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@question.reload.content).to eq('This is a Terrible Question')
  end

  scenario 'and sees updated description' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in('question-description', with: 'How can I describe such a terrible question?')
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@question.reload.description).to eq('How can I describe such a terrible question?')
  end

  scenario 'and sees updated question_type' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    bootstrap_select '#question-question_type', 'Text Area'
    wait_for_javascript_to_finish

    expect(@question.reload.question_type).to eq('textarea')
  end

  scenario 'and sees updated required' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    find('#question-required').click
    wait_for_javascript_to_finish

    expect(@question.reload.required).to eq(true)
  end

  scenario 'and sees updated is_dependent' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    find('#question-is_dependent').click
    wait_for_javascript_to_finish

    expect(@question.reload.is_dependent).to eq(true)
  end

  scenario 'and sees updated depender_id' do
    @question2 = create(:question, section: @section)
    @option    = create(:option, question: @question2, content: "What is the meaning of life?")
    
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    first('#question-is_dependent').click
    wait_for_javascript_to_finish

    bootstrap_select '#question-depender_id', 'What is the meaning of life?'
    wait_for_javascript_to_finish
    
    expect(@question.reload.depender_id).to eq(@option.id)
  end

  context 'and adds a question' do
    scenario 'and sees the new question' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      find('.edit-survey').click
      wait_for_javascript_to_finish

      find('.add-question').click
      wait_for_javascript_to_finish

      expect(page).to have_selector('.question', count: 2)
      expect(@section.questions.count).to eq(2)
    end
  end

  context 'and removes a question' do
    scenario 'and does not see the deleted question' do
      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      find('.edit-survey').click
      wait_for_javascript_to_finish

      find('.delete-question').click
      wait_for_javascript_to_finish

      expect(page).to_not have_selector('.question')
      expect(@section.questions.count).to eq(0)
    end
  end
end
