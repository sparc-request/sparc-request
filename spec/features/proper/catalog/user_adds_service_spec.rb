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

RSpec.describe 'User adds service to cart', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    @program    = create(:program, name: "Program", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    @service    = create(:service, name: "Service", abbreviation: "Service", organization: @program, pricing_map_count: 1)
  end

  context 'which is the first service of a new request' do
    scenario 'and sees the new request modal' do
      visit root_path
      wait_for_javascript_to_finish

      find('.provider-header').click
      find('.program-link').click
      click_button 'Add'

      expect(page).to have_selector('#modal-title', text: 'New or Existing', visible: true)
    end
  end

  context 'which is not in their cart' do
    scenario 'and sees the service in their cart' do
      visit root_path
      wait_for_javascript_to_finish

      find('.provider-header').click
      find('.program-link').click
      click_button 'Add'
      find('.yes-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector('.line-item .service', text: @service.abbreviation)
    end
  end

  context 'which is already in their cart' do
    scenario 'and sees a modal explanation' do
      sr  = create(:service_request_without_validations, status: 'first_draft')
      ssr = create(:sub_service_request_without_validations, service_request: sr, organization: @program, status: 'first_draft')
            create(:line_item, service_request: sr, sub_service_request: ssr, service: @service)

      visit catalog_service_request_path(srid: sr.id)
      wait_for_javascript_to_finish

      find('.provider-header').click
      find('.program-link').click
      click_button 'Add'
      wait_for_javascript_to_finish

      expect(page).to have_selector('#modal-title', text: 'Service Already Present', visible: true)
    end
  end
end
