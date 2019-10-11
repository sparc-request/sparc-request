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

RSpec.describe 'User wants to make a new Study', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  stub_config("use_epic", true)

  before :each do
    visit dashboard_root_path
    wait_for_javascript_to_finish
    click_button I18n.t('dashboard.protocols.new')
    click_link I18n.t('protocols.new', protocol_type: Study.model_name.human)
  end

  it 'should create a new Study' do
    fill_in 'protocol_short_title', with: 'asd'
    fill_in 'protocol_title', with: 'asd'
    bootstrap_typeahead '#primary_pi', 'Julia'
    find("[for='protocol_selected_for_epic_false']").click
    bootstrap_select '#protocol_funding_status', 'Funded'
    bootstrap_select '#protocol_funding_source', 'Federal'
    fill_in 'protocol_sponsor_name', with: 'asd'

    click_button I18n.t('actions.save')
    wait_for_javascript_to_finish

    expect(Study.count).to eq(1)
    expect(page).to have_current_path(dashboard_protocol_path(Protocol.last))
  end
end
