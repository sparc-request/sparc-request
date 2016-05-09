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

  def render_protocol_service_request_show(service_request)
    render('dashboard/service_requests/protocol_service_request_show',
      service_request: service_request,
      user: jug2,
      admin: false,
      permission_to_edit: false)
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

  describe 'displayed SubServiceRequest' do
    let!(:service_request) do
      create(:service_request_without_validations,
        protocol: protocol,
        service_requester: service_requester,
        status: 'draft')
    end

    context 'non-first_draft SubServiceRequest belongs to ServiceRequest' do
      it 'should display <protocol_id>-<ssr_id>, associated Organization, and status' do
        create(:sub_service_request,
          ssr_id: '1234',
          service_request: service_request,
          organization_id: organization.id)
        service_request.reload
        jug2.reload

        render_protocol_service_request_show service_request

        expect(response).to have_selector('td', exact: '9999-1234')
        expect(response).to have_selector('td', exact: 'Megacorp')
        expect(response).to have_selector('td', exact: 'Draft')
      end
    end

    context 'first_draft SubServiceRequest belongs to ServiceRequest' do
      it 'should not be displayed' do
        create(:sub_service_request,
          ssr_id: '1234',
          service_request: service_request,
          status: 'first_draft',
          organization_id: organization.id)
        service_request.reload
        jug2.reload

        render_protocol_service_request_show service_request

        expect(response).not_to have_selector('td', exact: '9999-1234')
      end
    end
  end

  describe '"Edit Original" button' do
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
          allow(jug2).to receive('can_edit_service_request?').
            with(service_request).and_return(true)

          render_protocol_service_request_show service_request

          expect(response).to have_selector('button', exact: 'Edit Original')
        end
      end

      context 'user cannot edit ServiceRequest' do
        it 'should not render' do
          allow(jug2).to receive('can_edit_service_request?').
            with(service_request).and_return(false)

          render_protocol_service_request_show service_request

          expect(response).not_to have_content('Edit Original')
        end
      end
    end

    context 'ServiceRequest with no SubServiceRequests' do
      it 'should not render' do
        allow(jug2).to receive('can_edit_service_request?').
          with(service_request).and_return(true)

        render_protocol_service_request_show service_request

        expect(response).to have_selector('button', exact: 'Edit Original')
      end
    end
  end

  describe '"Edit SSR" button' do
    let!(:service_request) do
      create(:service_request_without_validations,
      protocol: protocol,
      service_requester: service_requester,
      status: 'draft')
    end
    let!(:ssr) do
      create(:sub_service_request,
        ssr_id: '1234',
        service_request: service_request,
        status: 'draft',
        organization_id: organization.id)
    end
    context 'user can edit SubServiceRequest' do
      it 'should be visible' do
        jug2.reload
        allow(jug2).to receive('can_edit_sub_service_request?').and_return(true)
        service_request.reload

        render_protocol_service_request_show service_request

        expect(response).to have_selector('button', exact: 'Edit SSR')
      end
    end

    context 'user cannot edit SubServiceRequest' do
      it 'should not be visible' do
        jug2.reload
        allow(jug2).to receive('can_edit_sub_service_request?').and_return(false)
        service_request.reload

        render_protocol_service_request_show service_request

        expect(response).not_to have_content('Edit SSR')
      end
    end
  end

  describe '"Admin Edit" button' do
    context 'admin organizations of user includes Organization of SubServiceRequest' do
      it 'should display "Admin Edit" button with SubServiceRequest' do
        service_request = create(:service_request_without_validations,
          protocol: protocol,
          service_requester: service_requester,
          status: 'draft')
        create(:sub_service_request,
          ssr_id: '1234',
          service_request: service_request,
          organization_id: organization.id)
        service_request.reload
        jug2.reload
        allow(jug2).to receive(:admin_organizations).and_return([organization])

        render_protocol_service_request_show service_request

        expect(response).to have_selector('button', exact: 'Admin Edit')
      end
    end

    context 'admin organizations of user does not include Organization of SubServiceRequest' do
      it 'should not display "Admin Edit" button with SubServiceRequest' do
        service_request = create(:service_request_without_validations,
          protocol: protocol,
          service_requester: service_requester,
          status: 'draft')
        create(:sub_service_request,
          ssr_id: '1234',
          service_request: service_request,
          organization_id: organization.id)
        service_request.reload
        jug2.reload

        render_protocol_service_request_show service_request

        expect(response).not_to have_content('Admin Edit')
      end
    end
  end
end
