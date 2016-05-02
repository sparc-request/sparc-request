require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'patch archive' do
    it 'should toggle archived field of Protocol' do
      identity_stub = instance_double('Identity', id: 1)
      log_in_dashboard_identity(obj: identity_stub)

      protocol_stub = findable_stub(Protocol) do
        instance_double('Protocol',
          id: 1,
          type: :protocol_type,
          valid?: true)
      end
      allow(protocol_stub).to receive('toggle!')

      xhr :patch, :archive, id: 1, format: :js

      expect(protocol_stub).to have_received('toggle!').with(:archived)
    end
  end
end
