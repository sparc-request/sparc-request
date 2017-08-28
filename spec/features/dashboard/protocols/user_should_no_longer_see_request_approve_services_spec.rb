# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'User should no longer see request/approve auth user', js: true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true
          )
  end

  fake_login_for_each_test('johnd')

  scenario 'successfully - dashboard' do
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )

    visit dashboard_protocol_path(protocol)
    find('.edit-associated-user-button').click
    wait_for_javascript_to_finish

    expect(page).not_to have_css '#project_role_project_rights_request'
  end

  scenario 'successfully - Step 1' do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(
      :program, name: "Program", parent: provider, process_ssrs: true
    )
    service     = create(
      :service, name: "Service", abbreviation: "Service", organization: program
    )
    protocol = create(
      :unarchived_study_without_validations,
      primary_pi: user,
      research_master_id: 1
    )
    sr = create(
      :service_request_without_validations,
      status: 'first_draft',
      protocol: protocol
    )
    ssr = create(
      :sub_service_request_without_validations,
      service_request: @sr, organization: program, status: 'first_draft'
    )
    create(
      :line_item,
      service_request: sr, sub_service_request: ssr, service: service
    )
    create(:arm, protocol: protocol, visit_count: 1)
    create(
      :subsidy_map, organization: program, max_dollar_cap: 100, max_percentage: 100
    )

    visit protocol_service_request_path(sr)
    find('.edit-associated-user-button').click
    wait_for_javascript_to_finish

    expect(page).not_to have_css '#project_role_project_rights_request'
  end
end

