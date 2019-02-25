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

RSpec.describe 'User creates project', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program, pricing_map_count: 1)
    @sr         = create(:service_request_without_validations, status: 'first_draft')
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)

    allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
  end

  context 'and clicks \'New Project\'' do
    scenario 'and sees the project form' do
      visit protocol_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'New Project'
      wait_for_javascript_to_finish

      expect(page).to have_content('Project Information')
    end
  end

  context 'and fills out and submits the form' do
    scenario 'and sees the newly created protocol' do
      visit protocol_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'New Project'
      wait_for_javascript_to_finish

      fill_in 'protocol_short_title', with: 'asd'
      fill_in 'protocol_title', with: 'asd'
      bootstrap_select '#protocol_funding_status', 'Funded'
      bootstrap_select '#protocol_funding_source', 'Federal'

      fill_in 'protocol_project_roles_attributes_0_identity_id', with: 'Julia'
      page.execute_script %Q{ $('#protocol_project_roles_attributes_0_identity_id').trigger("keydown") }
      expect(page).to have_selector('.tt-suggestion')
      
      first('.tt-suggestion').click
      wait_for_javascript_to_finish

      click_button 'Save'
      wait_for_javascript_to_finish

      wait_for_page(protocol_service_request_path)
      expect(current_path).to eq(protocol_service_request_path)
      expect(Project.count).to eq(1)
    end
  end
end
