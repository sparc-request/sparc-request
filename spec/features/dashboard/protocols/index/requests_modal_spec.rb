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
      service_requester: jug2,
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
