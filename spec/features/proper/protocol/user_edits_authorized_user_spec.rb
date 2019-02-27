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

RSpec.describe 'User wants to edit an authorized user', js: true do
  let_there_be_lane
  let_there_be_j
  
  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program, pricing_map_count: 1)
    @protocol   = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr         = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
    @auth_u     = create(:project_role, identity: jpl6, protocol: @protocol, role: 'technician')
  end

  context 'and clicks the edit button' do
    scenario 'and sees the edit user modal' do
      visit protocol_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      all('.edit-associated-user-button').last.click
      wait_for_javascript_to_finish

      expect(page).to have_selector('#modal-title', text: 'Edit Authorized User', visible: true)
    end

    context 'and fills out and submits the form' do
      scenario 'and sees the updated authorized user' do
        visit protocol_service_request_path(srid: @sr.id)
        wait_for_javascript_to_finish

        all('.edit-associated-user-button').last.click
        wait_for_javascript_to_finish
        
        bootstrap_select '#project_role_role', 'PD/PI'

        click_button 'Save'
        wait_for_javascript_to_finish

        expect(@auth_u.reload.role).to eq('pi')
      end
    end
  end
end
