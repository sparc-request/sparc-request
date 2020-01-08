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

RSpec.describe 'User removes service from cart', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    @program    = create(:program, name: "Program", parent: provider, process_ssrs: true)
    @service    = create(:service, name: "A new Service", abbreviation: "New Service", organization: @program)
    @sr         = create(:service_request_without_validations, status: 'first_draft')
    @ssr        = create(:sub_service_request_without_validations, service_request: @sr, organization: @program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: @ssr, service: @service, optional: true)
  end

  it 'should remove the service' do
    visit root_path(srid: @sr.id)
    wait_for_javascript_to_finish

    find('.line-item .remove-service').click
    wait_for_javascript_to_finish

    expect(@sr.reload.line_items.count).to eq(0)
    expect(@sr.reload.sub_service_requests.count).to eq(0)
    expect(page).to have_no_content(@service.abbreviation)
    expect(page).to have_no_content(@program.name)
  end

  context 'service request was previously submitted' do
    it 'should remove the service after confirming' do
      @sr.update_attribute(:submitted_at, Date.today)
      @ssr.update_attribute(:submitted_at, Date.today)

      visit root_path(srid: @sr.id)
      wait_for_javascript_to_finish

      find('.line-item .remove-service').click
      confirm_swal
      wait_for_javascript_to_finish

      expect(@sr.reload.line_items.count).to eq(0)
      expect(@sr.reload.sub_service_requests.count).to eq(0)
      expect(page).to have_no_content(@service.abbreviation)
      expect(page).to have_no_content(@program.name)
    end
  end

  context 'from a page other than the catalog' do
    context 'and this is the last service' do
      it 'should redirect to the catalog' do
        visit protocol_service_request_path(srid: @sr.id)
        wait_for_javascript_to_finish

        find('.sub-service-request').click
        find('.line-item .remove-service').click
        confirm_swal
        wait_for_javascript_to_finish

        expect(page).to have_current_path(catalog_service_request_path(srid: @sr.id))
        expect(@sr.reload.line_items.count).to eq(0)
        expect(@sr.reload.sub_service_requests.count).to eq(0)
        expect(page).to have_no_content(@service.abbreviation)
        expect(page).to have_no_content(@program.name)
      end
    end
  end
end
