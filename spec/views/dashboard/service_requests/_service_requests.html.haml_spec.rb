require 'rails_helper'

RSpec.describe 'dashboard/service_requests/service_requests', type: :view do
  let_there_be_lane

  def render_service_requests(protocol, permission_to_edit=false)
    render 'dashboard/service_requests/service_requests',
      protocol: protocol,
      user: jug2,
      permission_to_edit: permission_to_edit,
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
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'draft')

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

  context 'Service Request with all \'first_draft\'' do
    it 'should not render' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

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
end
