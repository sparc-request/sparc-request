# Copyright © 2011-2017 MUSC Foundation for Research Development
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

RSpec.describe "User views Consolidated Request", js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'with all SSRs' do
    scenario 'and sees the Consolidated Request modal' do
      org      = create(:organization)
      protocol = create(:protocol_federally_funded, primary_pi: jug2, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request, service_request: sr, organization: org, protocol: protocol)

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      click_button 'View Consolidated Request'
      first('.view-full-calendar-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector('.full-calendar-modal', visible: true)
    end
  end

  context 'excluding draft SSRs' do
    scenario 'and sees the Consolidated Request modal' do
      org      = create(:organization)
      protocol = create(:protocol_federally_funded, primary_pi: jug2, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request, service_request: sr, organization: org, protocol: protocol)

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      click_button 'View Consolidated Request'
      all('.view-full-calendar-button')[1].click
      wait_for_javascript_to_finish

      expect(page).to have_selector('.full-calendar-modal', visible: true)
    end
  end
end
