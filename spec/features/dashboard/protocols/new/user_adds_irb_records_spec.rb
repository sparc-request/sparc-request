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

RSpec.describe 'User wants to make a new Study with IRB Records', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    visit new_dashboard_protocol_path(type: 'Study')
  end

  it 'should create a new Study with an IRB Record' do
    fill_in 'protocol_short_title', with: 'asd'
    fill_in 'protocol_title', with: 'asd'
    bootstrap_typeahead '#primary_pi', 'Julia'
    find("[for='protocol_selected_for_epic_false']").click
    bootstrap_select '#protocol_funding_status', 'Funded'
    bootstrap_select '#protocol_funding_source', 'Federal'
    fill_in 'protocol_sponsor_name', with: 'asd'

    find('#protocol_research_types_info_attributes_human_subjects + label').click

    find('#newIrbRecord').click
    wait_for_javascript_to_finish

    fill_in 'irb_record_pro_number', with: '1111111111'
    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    find('#newIrbRecord').click
    wait_for_javascript_to_finish

    fill_in 'irb_record_pro_number', with: '2222222222'
    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(page).to have_selector('.delete-irb[disabled=disabled]')

    all('.delete-irb').last.click
    wait_for_javascript_to_finish

    find('.edit-irb').click
    wait_for_javascript_to_finish

    fill_in 'irb_record_irb_of_record', with: 'My IRB Board'
    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    click_button I18n.t('actions.save')
    wait_for_javascript_to_finish

    expect(IrbRecord.count).to eq(1)
    irb = IrbRecord.first
    expect(irb.pro_number).to eq('1111111111')
    expect(irb.irb_of_record).to eq('My IRB Board')
  end
end
