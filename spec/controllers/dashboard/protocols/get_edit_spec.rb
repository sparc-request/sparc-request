require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get edit' do
    describe 'authorization' do
      render_views

      let!(:identity_stub) { instance_double('Identity', id: 1) }

      before(:each) do
        log_in_dashboard_identity(obj: identity_stub)
      end

      context 'user not authorized to edit Protocol' do
        it 'should render error message' do
          protocol = findable_stub(Protocol) do
            instance_double(Protocol, id: 1, type: :protocol_type)
          end
          authorize(identity_stub, protocol, can_edit: false)

          get :edit, id: 1

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end

    it 'should set @protocol_type to type of Protocol and populate (something?) for edit' do
      identity_stub = instance_double('Identity',
        id: 1)
      log_in_dashboard_identity(obj: identity_stub)

      protocol_stub = findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          type: :protocol_type,
          valid?: true)
      end
      allow(protocol_stub).to receive(:populate_for_edit)
      authorize(identity_stub, protocol_stub, can_edit: true)

      get :edit, id: 1

      expect(assigns(:protocol_type)).to eq(:protocol_type)
      expect(protocol_stub).to have_received(:populate_for_edit)
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
end
