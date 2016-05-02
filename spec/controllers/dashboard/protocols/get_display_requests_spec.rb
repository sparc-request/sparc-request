require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get display_requests' do
    it 'should set @protocol_role and @permission_to_edit' do
      identity = instance_double('Identity',
        id: 1)
      log_in_dashboard_identity(obj: identity)

      project_role_stub = instance_double('ProjectRole',
      'can_edit?' => :permission_to_edit)

      protocol_stub = findable_stub(Protocol) do
        instance_double('Protocol', id: 1)
      end
      allow(protocol_stub).to receive_message_chain(:project_roles, :find_by_identity_id).
        with(1).and_return(project_role_stub)

      xhr :get, :display_requests, id: 1, format: :js

      expect(assigns(:protocol_role)).to eq(project_role_stub)
      expect(assigns(:protocol)).to eq(protocol_stub)
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
