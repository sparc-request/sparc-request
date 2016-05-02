require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'patch update_protocol_type' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    describe 'authorization' do
      context 'user not authorized to edit Protocol' do
        it 'should render error message' do
          protocol_stub = findable_stub(Protocol) do
            instance_double(Protocol,
              id: 1,
              type: :protocol_type)
          end
          authorize(identity_stub, protocol_stub, can_edit: false)

          xhr :patch, :update_protocol_type, id: 1, format: :js

          expect(response).to render_template('service_requests/_authorization_error')
        end
      end
    end

    it 'should update Protocol type to params[:type]' do
      protocol = create(:protocol_without_validations, type: 'Study')
      authorize(identity_stub, protocol.becomes(Study), can_edit: true)

      xhr :patch, :update_protocol_type, id: protocol.id, type: 'Project', format: :js

      expect(assigns(:protocol).class.name).to eq('Project')
      expect(assigns(:protocol).type).to eq('Project')
      expect(assigns(:protocol)).to be_persisted
    end

    it 'should populate Protocol for edit' do
      protocol_stub = findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          type: :protocol_type)
      end
      allow(protocol_stub).to receive(:update_attribute)
      expect(protocol_stub).to receive(:populate_for_edit)
      authorize(identity_stub, protocol_stub, can_edit: true)

      xhr :patch, :update_protocol_type, id: 1, type: 'Project', format: :js
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
