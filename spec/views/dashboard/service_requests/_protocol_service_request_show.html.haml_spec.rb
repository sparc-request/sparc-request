# TODO rewrite with stubs
require 'rails_helper'

RSpec.describe 'dashboard/service_requests/protocol_service_request_show', type: :view do
  # TODO replace Lane with Identity stub
  let_there_be_lane

  let!(:protocol) do
    create(:protocol_federally_funded,
      :without_validations,
      id: 9999,
      primary_pi: jug2,
      type: 'Study',
      archived: false)
  end

  let!(:service_requester) do
    create(:identity, first_name: 'Some', last_name: 'Guy')
  end

  let!(:organization) do
    create(:organization,
      type: 'Institution',
      name: 'Megacorp',
      service_provider: create(:identity,
        first_name: 'Easter',
        last_name: 'Bunny'))
  end

  def render_protocol_service_request_show(service_request, permission_to_edit=false)
    render('dashboard/service_requests/protocol_service_request_show',
      service_request: service_request,
      user: jug2,
      admin: false,
      permission_to_edit: permission_to_edit)
  end

  describe 'header' do
    context 'submitted ServiceRequest' do
      it 'should display id, status, and submitted date' do
        service_request = create(:service_request_without_validations,
          id: 9999,
          protocol: protocol,
          service_requester: jug2,
          status: 'submitted',
          submitted_at: DateTime.now)
        create(:sub_service_request,
          ssr_id: '0001',
          service_request: service_request,
          organization: organization)

        render_protocol_service_request_show service_request

        expect(response).to have_content "Service Request: 9999 - Submitted - #{service_request.submitted_at.strftime('%D')}"
      end
    end

    context 'unsubmitted ServiceRequest' do
      it 'should display id, status, and last modified date' do
        service_request = create(:service_request_without_validations,
          id: 9999,
          protocol: protocol,
          service_requester: jug2,
          status: 'draft')
        create(:sub_service_request,
          ssr_id: '0001',
          service_request: service_request,
          organization: organization)

        render_protocol_service_request_show service_request

        expect(response).to have_content "Service Request: 9999 - Draft - #{service_request.updated_at.strftime('%D')}"
      end
    end
  end

  describe '"Modify Request" button' do
    let!(:service_request) do
      create(:service_request_without_validations,
        protocol: protocol,
        service_requester: service_requester,
        status: 'draft')
    end

    context 'ServiceRequest with SubServiceRequest' do
      let!(:ssr) do
        create(:sub_service_request,
          ssr_id: '1234',
          service_request: service_request,
          status: 'draft',
          organization_id: organization.id)
      end

      context 'user can edit ServiceRequest' do
        it 'should render' do
          render_protocol_service_request_show(service_request, true)

          expect(response).to have_selector('button', text: 'Modify Request')
        end
      end

      context 'user cannot edit ServiceRequest' do
        it 'should not render' do
          render_protocol_service_request_show service_request

          expect(response).not_to have_selector('button', text: 'Modify Request')
        end
      end
    end
  end
end
