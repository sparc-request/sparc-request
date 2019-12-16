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

RSpec.describe "User views Consolidated Request", js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'with all SSRs' do
    it 'should show the consolidated request modal' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:study_federally_funded, primary_pi: jug2)
      sr        = create(:service_request_without_validations, protocol: protocol)
      ssr       = create(:sub_service_request, service_request: sr, organization: org, protocol: protocol, status: 'draft')
                  create(:line_item, sub_service_request: ssr, service_request: sr, service: service)

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      find('.view-consolidated-request').click
      first('.view-consolidated-request + .dropdown-menu .dropdown-item').click
      wait_for_javascript_to_finish

      expect(page).to have_selector('#consolidatedRequestModal')
    end
  end

  context 'excluding draft SSRs' do
    it 'should show the consolidated request modal' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:study_federally_funded, primary_pi: jug2)
      sr        = create(:service_request_without_validations, protocol: protocol)
      ssr       = create(:sub_service_request, service_request: sr, organization: org, protocol: protocol)
                  create(:line_item, sub_service_request: ssr, service_request: sr, service: service)

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      find('.view-consolidated-request').click
      all('.view-consolidated-request + .dropdown-menu .dropdown-item').last.click
      wait_for_javascript_to_finish

      expect(page).to have_selector('#consolidatedRequestModal')
    end
  end
end
