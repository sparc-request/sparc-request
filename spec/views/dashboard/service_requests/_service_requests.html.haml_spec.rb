require 'rails_helper'

RSpec.describe 'dashboard/service_requests/service_requests', type: :view do
  let_there_be_lane

  context 'Protocol has no ServiceRequests' do
    it 'should display "Add Services" button' do
      protocol = instance_double('Protocol',
        service_requests: [],
        :has_first_draft_service_request? => false)
      render 'dashboard/service_requests/service_requests',
        protocol: protocol,
        permission_to_edit: false
      expect(response).to have_selector('button', exact: 'Add Services')
    end
  end

  context 'Protocol has all ServiceRequests in first_draft' do
    it 'should indicate that the requests are in progress' do
      protocol = instance_double('Protocol',
        service_requests: [:at_least_one_service_request],
        :has_first_draft_service_request? => true)
      render 'dashboard/service_requests/service_requests',
        protocol: protocol,
        permission_to_edit: false
      expect(response).to have_content('Request in progress.')
    end
  end

  context 'Protocol has some ServiceRequest not in first_draft' do
    let!(:protocol) do
      create(:protocol_federally_funded,
        :without_validations,
        id: 9999,
        primary_pi: jug2,
        type: 'Study',
        archived: false,
        short_title: 'My Awesome Short Title')
    end
    let!(:service_request_d) do
      sr = create(:service_request_without_validations, id: 1234, protocol: protocol, service_requester: jug2, status: 'draft')
      create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization))
      sr
    end

    before(:each) do
      render 'dashboard/service_requests/service_requests',
        protocol: protocol,
        permission_to_edit: false,
        user: jug2,
        admin: false
    end

    it 'should show that SubServiceRequest' do
      expect(response).to render_template('dashboard/service_requests/_protocol_service_request_show',
        locals: {
          service_request: service_request_d,
          user: jug2,
          admin: false,
          permission_to_edit: false
          })
    end
  end
end
