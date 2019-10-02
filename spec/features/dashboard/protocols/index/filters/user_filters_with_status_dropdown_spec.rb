# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe "User selects statuses and filters", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  scenario "and sees protocols with statuses" do
    organization        = create(:organization)
    protocol_draft      = create(:study_without_validations, primary_pi: jug2)
    sr_draft            = create(:service_request_without_validations, protocol: protocol_draft)
                          create(:sub_service_request, status: 'draft', service_request: sr_draft, organization: organization)
    protocol_submitted  = create(:study_without_validations, primary_pi: jug2)
    sr_submitted        = create(:service_request_without_validations, protocol: protocol_submitted)
                          create(:sub_service_request, status: 'submitted', service_request: sr_submitted, organization: organization)

    visit dashboard_protocols_path
    wait_for_javascript_to_finish

    bootstrap_multiselect("#filterrific_with_status", ["Draft"])
    click_button I18n.t('actions.filter')
    wait_for_javascript_to_finish

    expect(page).to have_selector("#protocolsTable tbody tr", count: 1)
    expect(page).to have_content(protocol_draft.short_title)
    expect(page).to_not have_content(protocol_submitted.short_title)
  end
end
