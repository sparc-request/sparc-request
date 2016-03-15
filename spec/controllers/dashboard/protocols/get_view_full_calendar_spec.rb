require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get view_full_calendar' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    describe 'authorization' do
      render_views

      context 'user not authorized to view Protocol' do
        it 'should render error message' do
          protocol_stub = instance_double('Protocol',
            id: 1,
            type: :protocol_type)
          stub_find_protocol(protocol_stub)
          authorize(identity_stub, protocol_stub, can_view: false)

          xhr :get, :view_full_calendar, id: 1

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end
  end

  def authorize(identity, protocol, opts = {})
    auth_mock = instance_double('ProtocolAuthorizer',
      'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
      'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
    expect(ProtocolAuthorizer).to receive(:new).
      with(protocol, identity).
      and_return(auth_mock)
  end

  def stub_find_protocol(protocol_stub)
    allow(Protocol).to receive(:find).with(protocol_stub.id.to_s).and_return(protocol_stub)
  end
end
