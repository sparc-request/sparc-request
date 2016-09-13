# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe 'requests modal', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    page
  end

  let!(:protocol) do
    create(:unarchived_study_without_validations,
      id: 9999,
      primary_pi: jug2)
  end

  let!(:service_request) do
    create(:service_request_without_validations,
      protocol: protocol,
      status: 'draft')
  end

  let!(:organization) do
    create(:organization,
      admin: jug2,
      type: 'Institution')
  end

  let!(:sub_service_request) do
    create(:sub_service_request,
      id: 9999,
      ssr_id: '1234',
      service_request: service_request,
      status: 'draft',
      organization_id: organization.id)
  end

  context 'user clicks "Modify Request" button' do
    it 'should take user to SPARC homepage' do
      page = visit_protocols_index_page
      page.search_results.protocols.first.requests_button.click
      expect(page).to have_requests_modal
      page.requests_modal.service_requests.first.modify_request_button.click
      wait_for_javascript_to_finish

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end
  end

  context 'user clicks "View" button' do
    it 'should reveal modal containing study schedule' do
      page = visit_protocols_index_page
      page.search_results.protocols.first.requests_button.click
      wait_for_javascript_to_finish

      expect(page).to have_requests_modal

      page.requests_modal.service_requests.first.sub_service_requests.first.view_button.click
      wait_for_javascript_to_finish

      expect(page).to have_selector ".modal-dialog.user-view-ssr-modal"
    end
  end

  context 'user clicks "Edit" button' do
    it 'should take user to SPARC homepage' do
      page = visit_protocols_index_page
      page.search_results.protocols.first.requests_button.click
      wait_for_javascript_to_finish
      
      expect(page).to have_requests_modal

      page.requests_modal.service_requests.first.sub_service_requests.first.edit_button.click
      wait_for_javascript_to_finish

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end
  end

  context 'user clicks "Admin Edit" button' do
    it 'should take user to Dashboard SubServiceRequest show' do
      page = visit_protocols_index_page
      page.search_results.protocols.first.requests_button.click
      wait_for_javascript_to_finish
      expect(page).to have_requests_modal

      page.requests_modal.service_requests.first.sub_service_requests.first.admin_edit_button.click
      wait_for_javascript_to_finish

      expect(URI.parse(current_url).path).to eq '/dashboard/sub_service_requests/9999'
    end
  end
end
