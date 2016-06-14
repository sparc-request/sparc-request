require 'rails_helper'

RSpec.describe 'dashboard/service_requests/service_requests', type: :view do
  let_there_be_lane

  def render_service_requests(protocol, permission_to_edit=false, sp_only_admin_orgs=[])
    render 'dashboard/service_requests/service_requests',
      protocol: protocol,
      user: jug2,
      permission_to_edit: permission_to_edit,
      permission_to_view: false,
      sp_only_admin_orgs: sp_only_admin_orgs,
      view_only: false
  end

  context 'Protocol has no SubServiceRequests' do
    context 'and user has appropriate rights' do
      it 'should display enabled "Add Services" button' do
        protocol  = create(:unarchived_study_without_validations, primary_pi: jug2)

        render_service_requests(protocol, true)

        expect(response).to have_selector('button:not(.disabled)', text: 'Add Services')
      end
    end

    context 'and user does not have appropriate rights' do
      it 'should display disabled "Add Services" button' do
        protocol  = create(:unarchived_study_without_validations, primary_pi: create(:identity))

        render_service_requests(protocol)

        expect(response).to have_selector('button.disabled', text: 'Add Services')
      end
    end
  end

  context 'Protocol has SubServiceRequests' do
    it 'should render Service Requests with Sub Service Requests' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization))

      render_service_requests(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request,
        user: jug2,
        permission_to_edit: false,
        view_only: false
      }
    )
    end

    it 'should not render Service Requests without Sub Service Requests' do
      protocol                  = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request           = create(:service_request_without_validations, protocol: protocol)
      service_request_with_ssr  = create(:service_request_without_validations, protocol: protocol)
                                  create(:sub_service_request_without_validations, service_request: service_request_with_ssr, organization: create(:organization))

        render_service_requests(protocol)

        expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
        }
      )
    end
  end

  context 'Service Request with all \'draft\' or \'first_draft\'' do
    it 'should render if the user is an Authorized User' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'draft')
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

      render_service_requests(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
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

      render_service_requests(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
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

      render_service_requests(protocol, false, [organization])

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
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

      render_service_requests(protocol, false, [organization])

      expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: hidden_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
        }
      )
    end
  end
end