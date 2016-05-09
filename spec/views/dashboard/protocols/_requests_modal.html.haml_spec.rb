# TODO rewrite with stubs
require 'rails_helper'

RSpec.describe 'dashboard/protocols/requests_modal', type: :view do
  let_there_be_lane

  def render_requests_modal(protocol)
    render 'dashboard/protocols/requests_modal',
      protocol: protocol,
      user: jug2,
      permission_to_edit: false,
      admin: false
  end

  it 'should only show ServiceRequests with SubServiceRequests' do
    protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_with_ssr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
    create(:sub_service_request, ssr_id: '0001', service_request: service_request_with_ssr, organization: create(:organization))
    service_request_without_ssr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)

    render_requests_modal(protocol)

    expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_with_ssr,
        user: jug2,
        permission_to_edit: false,
        admin: false
      })

    expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_without_ssr,
        user: jug2,
        permission_to_edit: false,
        admin: false
      })
  end
end
