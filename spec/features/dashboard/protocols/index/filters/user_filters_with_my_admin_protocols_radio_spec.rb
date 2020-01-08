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

RSpec.describe "User filters using \"My Admin Protocols\"", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  before :each do
    organization    = create(:organization)
    @protocol       = create(:study_without_validations, primary_pi: jug2)
    @sr             = create(:service_request_without_validations, protocol: @protocol)
                      create(:sub_service_request, service_request: @sr, organization: organization)
    admin_org       = create(:organization)
    @admin_protocol = create(:study_without_validations, primary_pi: jug2)
    @admin_sr       = create(:service_request_without_validations, protocol: @admin_protocol)
                      create(:sub_service_request, service_request: @admin_sr, organization: admin_org)

    create(:service_provider, identity: jug2, organization: admin_org)

    visit dashboard_protocols_path
    wait_for_javascript_to_finish

    find("#filterrific_admin_filter_for_admin_#{jug2.id}").click
    click_button I18n.t('actions.filter')
    wait_for_javascript_to_finish
  end

  scenario "and sees their admin protocols" do
    expect(page).to have_selector("#protocolsTable tbody tr", count: 1)
    expect(page).to have_content(@admin_protocol.short_title)
    expect(page).to_not have_content(@protocol.short_title)
  end
end
