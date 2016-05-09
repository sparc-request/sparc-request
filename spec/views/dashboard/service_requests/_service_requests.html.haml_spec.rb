require 'rails_helper'

RSpec.describe 'dashboard/service_requests/service_requests', type: :view do
  let!(:logged_in_identity) { build_stubbed(:identity) }

  context 'Protocol has no SubServiceRequests' do
    context 'and user has appropriate rights' do
      it 'should display "Add Services" button' do
        protocol = instance_double('Protocol',
          id: 1,
          service_requests: [],
          sub_service_requests: [],
          has_first_draft_service_request?: false)

        render 'dashboard/service_requests/service_requests',
          protocol: protocol,
          permission_to_edit: true

        expect(response).to have_selector('button', exact: 'Add Services')
      end
    end

    context 'and user does not have appropriate rights' do
      it 'should not display "Add Services" button' do
        protocol = instance_double('Protocol',
          id: 1,
          service_requests: [],
          sub_service_requests: [],
          has_first_draft_service_request?: false)

        render 'dashboard/service_requests/service_requests',
          protocol: protocol,
          permission_to_edit: false

        expect(response).to_not have_selector('button', exact: 'Add Services')
      end
    end
  end

  context 'Protocol has some SubServiceRequest' do
    before(:each) do
      protocol = build_stubbed(:protocol)
      @service_request = build_stubbed(:service_request, protocol: protocol)
      allow(protocol).to receive(:service_requests).
        and_return([@service_request])

      organization = build_stubbed(:organization)
      sub_service_request = build_stubbed(:sub_service_request,
        service_request: @service_request,
        organization: organization)
      allow(protocol).to receive(:sub_service_requests).
        and_return([sub_service_request])
      allow(@service_request).to receive(:sub_service_requests).
        and_return([sub_service_request])

      render 'dashboard/service_requests/service_requests',
        protocol: protocol,
        permission_to_edit: false,
        user: logged_in_identity,
        admin: false
    end

    it 'should show that SubServiceRequest' do
      expect(response).to render_template('dashboard/service_requests/_protocol_service_request_show',
        locals: {
          service_request: @service_request,
          user: logged_in_identity,
          admin: false,
          permission_to_edit: false
        })
    end
  end
end
