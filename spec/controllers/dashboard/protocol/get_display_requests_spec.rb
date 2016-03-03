require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'get display_requests' do
    it 'should set @protocol_role to user\'s ProjectRole associated with Protocol' do
      identity = create(:identity)
      log_in_dashboard_identity(obj: identity)

      protocol = create(:protocol_without_validations,
        type: 'Project').becomes(Project)
      pr = create(:project_role,
        protocol_id: protocol.id,
        identity_id: identity.id,
        role: 'primary-pi',
        project_rights: 'request')

      xhr :get, :display_requests, id: protocol.id, format: :js

      expect(assigns(:protocol_role)).to eq(pr)
      expect(assigns(:protocol)).to eq(protocol)
    end
  end
end
