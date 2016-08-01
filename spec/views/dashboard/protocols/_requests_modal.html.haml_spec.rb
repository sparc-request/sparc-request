# TODO rewrite with stubs
require 'rails_helper'

RSpec.describe 'dashboard/protocols/requests_modal', type: :view do
  let_there_be_lane

  def render_requests_modal(protocol)
    render 'dashboard/protocols/requests_modal',
      protocol: protocol,
      user: jug2,
      permission_to_edit: false,
      view_only: true
  end

  it 'should render Service Requests with Sub Service Requests' do
    protocol                  = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_with_ssr  = create(:service_request_without_validations, protocol: protocol)
                                create(:sub_service_request, service_request: service_request_with_ssr, organization: create(:organization), status: 'draft')

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
    service_request_without_ssr = create(:service_request_without_validations, protocol: protocol)
    
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

  context 'Service Request with all \'first_draft\'' do
    it 'should not render' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

      render_requests_modal(protocol)

      expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end
  end
end
