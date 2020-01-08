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
    @service    = create(:service, name: "A new Service", abbreviation: "New Service", organization: @program, pricing_map_count: 1)
  end

  context 'starting a new request' do
    it 'should start a new request' do
      visit root_path
      wait_for_javascript_to_finish

      find('.provider-link').click
      find('.program-link').click
      find('.add-service').click
      wait_for_javascript_to_finish

      expect(page).to have_content(I18n.t('proper.catalog.new_request.header'))
      confirm_swal
      wait_for_javascript_to_finish

      expect(ServiceRequest.count).to eq(1)
      sr = ServiceRequest.first
      expect(sr.line_items.count).to eq(1)
      expect(page).to have_selector('#cart .line-item', text: @service.abbreviation)
      expect(page).to have_current_path(root_path(srid: sr.id))
    end
  end

  context 'request already started' do
    before :each do
      @sr       = create(:service_request_without_validations)
      @service2 = create(:service, name: "Another new Service", abbreviation: "New Service 2", organization: @program, pricing_map_count: 1)
      ssr       = create(:sub_service_request, service_request: @sr, organization: @program)
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: @service2)
    end

    context 'the service is not already in the cart' do
      it 'should add the service to their cart' do
        visit root_path(srid: @sr.id)
        wait_for_javascript_to_finish

        find('.provider-link').click
        find('.program-link').click
        first('.add-service').click
        wait_for_javascript_to_finish

        expect(@sr.reload.line_items.count).to eq(2)
        expect(page).to have_selector('#cart .line-item', text: @service2.abbreviation)
      end
    end

    context 'the service is already in the cart' do
      it 'should not add the service and show an error' do
        visit root_path(srid: @sr.id)
        wait_for_javascript_to_finish

        find('.provider-link').click
        find('.program-link').click
        all('.add-service').last.click
        wait_for_javascript_to_finish

        expect(@sr.reload.line_items.count).to eq(1)
        expect(page).to have_content(I18n.t('proper.cart.duplicate_service.header'))
      end
    end
  end
end
