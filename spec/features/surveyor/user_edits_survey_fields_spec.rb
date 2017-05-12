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

RSpec.describe 'User edits survey fields', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    @survey = create(:survey)

    stub_const("SITE_ADMINS", ['jug2'])
  end

  scenario 'and sees updated access code' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in 'survey-access_code', with: 'access-denied'
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@survey.reload.access_code).to eq('access-denied')
  end

  scenario 'and sees updated version' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in 'survey-version', with: '9000'
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@survey.reload.version).to eq(9000)
  end

  scenario 'and sees updated display order' do
    create(:survey, display_order: 1)

    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    first('.edit-survey').click
    wait_for_javascript_to_finish

    bootstrap_select '#survey-display_order', 'Add as last'
    wait_for_javascript_to_finish

    expect(@survey.reload.display_order).to eq(2)
  end

  scenario 'and sees updated active' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    find('#survey-active').click
    wait_for_javascript_to_finish

    expect(@survey.reload.active).to eq(true)
  end

  scenario 'and sees updated title' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in('survey-title', with: 'This is a Terrible Survey')
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@survey.reload.title).to eq('This is a Terrible Survey')
  end

  scenario 'and sees updated description' do
    visit surveyor_surveys_path
    wait_for_javascript_to_finish

    find('.edit-survey').click
    wait_for_javascript_to_finish

    fill_in('survey-description', with: 'How can I describe such a terrible survey?')
    find('.modal-title').click
    wait_for_javascript_to_finish

    expect(@survey.reload.description).to eq('How can I describe such a terrible survey?')
  end
end
