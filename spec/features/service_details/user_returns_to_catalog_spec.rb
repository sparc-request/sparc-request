# Copyright © 2011-2018 MUSC Foundation for Research Development
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

RSpec.describe 'User returns to catalog', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    # Data setup:
    #
    # institution1        institution2
    # |        |
    # program1 program2
    # |        |
    # service1 service2
    # |        |
    # @ssr1    ssr2
    # ^--------^---------sr----protocol
    institution1 = create(:institution, name: "Institution1")
    create(:institution, name: "Institution2")
    provider    = create(:provider, name: "Provider", parent: institution1)
    program1    = create(:program, name: "Program1", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    program2    = create(:program, name: "Program2", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    service1    = create(:service, name: "Service1", abbreviation: "Service1", organization: program1, pricing_map_count: 1)
    service2    = create(:service, name: "Service2", abbreviation: "Service2", organization: program2, pricing_map_count: 1)

    protocol = create(:protocol_without_validations, primary_pi: jug2)
    @sr      = create(:service_request_without_validations, status: "first_draft", protocol_id: protocol.id)
    @ssr1    = create(:sub_service_request_without_validations, service_request: @sr, organization: program1, status: "draft", protocol: protocol)
    ssr2     = create(:sub_service_request_without_validations, service_request: @sr, organization: program2, status: "draft", protocol: protocol)
    create(:line_item, service_request: @sr, sub_service_request: @ssr1, service: service1)
    create(:line_item, service_request: @sr, sub_service_request: ssr2, service: service2)
  end

  def visit_service_details_page(service_request: nil, sub_service_request: nil)
    params = if sub_service_request
               "?sub_service_request_id=#{sub_service_request.id}"
             else
               ""
             end
    visit "/service_requests/#{service_request.id}/service_details/" + params
  end

  context 'when editing a ServiceRequest' do
    before(:each) do
      visit_service_details_page(service_request: @sr)
      click_link("Return to Catalog")
      expect(page).to have_content("Browse Service Catalog")
    end

    scenario 'sees Services belonging to each SubServiceRequest in the cart' do
      cart = page.find(".panel", text: /My Services/)
      expect(cart).to have_content("Service1")
      expect(cart).to have_content("Service2")
    end

    scenario 'sees each Institution in the Service accordion' do
      service_accordion = page.find(".panel", text: /Browse Service Catalog/)
      expect(service_accordion).to have_content("Institution1")
      expect(service_accordion).to have_content("Institution2")
    end
  end

  context 'when editing a SubServiceRequest' do
    before(:each) do
     visit_service_details_page(service_request: @sr, sub_service_request: @ssr1)
     click_link("Return to Catalog")
     expect(page).to have_content("Browse Service Catalog")
    end

    scenario 'sees Services belonging only to the SubServiceRequest in the cart' do
      cart = page.find(".panel", text: /My Services/)
      expect(cart).to have_content("Service1")
      expect(cart).to_not have_content("Service2")
    end

    scenario 'sees only the Institution related to the SubServiceRequest' do
      service_accordion = page.find(".panel", text: /Browse Service Catalog/)
      expect(service_accordion).to have_content("Institution1")
      expect(service_accordion).not_to have_content("Institution2")
    end
  end
end
