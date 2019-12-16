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

require 'rails_helper'

RSpec.describe 'User clicks Requests button', js: true do
  let_there_be_lane
  fake_login_for_each_test

  let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: jug2) }
  let!(:service_request) { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
  let!(:organization) { create(:organization, :process_ssrs, admin: jug2, type: 'Institution') }
  let!(:sub_service_request) { create(:sub_service_request, ssr_id: '1234', service_request: service_request, status: 'draft', organization_id: organization.id, protocol_id: protocol.id) }

  it 'should display the requests modal' do
    visit dashboard_root_path
    wait_for_javascript_to_finish

    click_link Protocol.human_attribute_name(:requests)
    wait_for_javascript_to_finish

    expect(page).to have_selector('#protocolRequestsModal')
    expect(page).to have_selector('.service-requests-table')
  end
end
