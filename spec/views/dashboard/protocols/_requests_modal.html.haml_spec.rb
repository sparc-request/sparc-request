# TODO rewrite with stubs
require 'rails_helper'

RSpec.describe 'dashboard/protocols/requests_modal', type: :view do
  let_there_be_lane

  def render_requests_modal(protocol, sp_only_admin_orgs=[])
    render 'dashboard/protocols/requests_modal',
      protocol: protocol,
      user: jug2,
      permission_to_edit: false,
      permission_to_view: false,
      sp_only_admin_orgs: sp_only_admin_orgs,
      view_only: true
  end

  it 'should render Service Requests with Sub Service Requests' do
    protocol                  = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_with_ssr  = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
                                create(:sub_service_request, ssr_id: '0001', service_request: service_request_with_ssr, organization: create(:organization))

    render_requests_modal(protocol)

    expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_with_ssr,
        user: jug2,
        permission_to_edit: false,
        view_only: true
      }
    )
  end

  it 'should not render Service Request without Sub Service Requests' do
    protocol                    = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_without_ssr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
    
    render_requests_modal(protocol)

    expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_without_ssr,
        user: jug2,
        permission_to_edit: false,
        view_only: true
      }
    )
  end

  context 'Service Request with all \'draft\' or \'first_draft\'' do
    it 'should render if the user is an Authorized User' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'draft')
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

      render_requests_modal(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end

    it 'should render for Super Users' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: create(:identity))
      service_request = create(:service_request_without_validations, protocol: protocol)
      organization    = create(:organization)
                        create(:super_user, identity: jug2, organization: organization)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                        create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'first_draft')

      render_requests_modal(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end

    it 'should render for Service Providers' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: create(:identity))
      service_request = create(:service_request_without_validations, protocol: protocol)
      organization    = create(:organization)
                        create(:service_provider, identity: jug2, organization: organization)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                        create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'first_draft')

      render_requests_modal(protocol, [organization])

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end

    it 'should not render for Service Providers not in that Service Request' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: create(:identity))
      service_request = create(:service_request_without_validations, protocol: protocol)
      organization    = create(:organization)
                        create(:service_provider, identity: jug2, organization: organization)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
      hidden_request  = create(:service_request_without_validations, protocol: protocol)
      hidden_org      = create(:organization)
                        create(:sub_service_request_without_validations, service_request: hidden_request, organization: hidden_org, status: 'draft')
                        create(:sub_service_request_without_validations, service_request: hidden_request, organization: hidden_org, status: 'first_draft')

      render_requests_modal(protocol, [organization])

      expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: hidden_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end
  end
end
