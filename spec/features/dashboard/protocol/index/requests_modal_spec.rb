require 'rails_helper'

RSpec.describe 'requests modal', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  def open_modal
    visit_protocols_index_page
    @page.protocols.first.requests_button.click
    @page.requests_modal
  end

  let!(:protocol) do
    create(:protocol_federally_funded,
      :without_validations,
      id: 9999,
      primary_pi: jug2,
      type: 'Study',
      archived: false)
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

  scenario 'user clicks "Edit Original" button' do
    modal = open_modal
    modal.service_requests.first.edit_original_button.click
  end

  scenario 'user clicks "View SSR" button' do
    modal = open_modal
    modal.service_requests.first.sub_service_requests.first.view_ssr_button.click
  end

  scenario 'user clicks "Edit SSR" button' do
    modal = open_modal
    modal.service_requests.first.sub_service_requests.first.edit_ssr_button.click
  end

  scenario 'user clicks "Admin Edit" button' do
    modal = open_modal
    modal.service_requests.first.sub_service_requests.first.admin_edit_button.click
    expect(URI.parse(current_url).path).to eq '/dashboard/sub_service_requests/9999'
  end
end
