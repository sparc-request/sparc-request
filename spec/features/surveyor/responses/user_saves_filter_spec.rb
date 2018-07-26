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

RSpec.describe 'User saves a response filters', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config('site_admins', ['jug2'])

  scenario 'and sees the saved filter' do
    survey          = create(:system_survey, title: 'Serviceable Survey', active: true)
    survey_response = create(:response, survey: survey)
                      create(:question_response, response: survey_response)

    visit surveyor_responses_path
    wait_for_javascript_to_finish

    first('#filterrific_with_state + .btn-group').click
    first('.dropdown-menu.open span.text', text: I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:active]).click
    first('.dropdown-menu.open span.text', text: I18n.t(:surveyor)[:response_filters][:fields][:state_filters][:inactive]).click
    first('.panel-heading').click
    find('#filterrific_start_date').click
    first('.panel-heading').click
    find('#filterrific_end_date').click
    first('.panel-heading').click
    find('#filterrific_include_incomplete').click

    click_link I18n.t(:actions)[:save]
    wait_for_javascript_to_finish

    fill_in 'response_filter_name', with: 'My Filters'
    click_button I18n.t(:actions)[:save]
    wait_for_javascript_to_finish

    filter = ResponseFilter.first

    expect(page).to have_selector('.apply-filter', text: 'My Filters')
    expect(filter.with_state).to eq(['1','0'])
    expect(filter.include_incomplete).to eq(true)
  end
end
