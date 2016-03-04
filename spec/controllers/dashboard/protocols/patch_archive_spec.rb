require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'patch archive' do
    it 'should toggle archived field of Protocol' do
      identity_stub = instance_double('Identity', id: 1)
      log_in_dashboard_identity(obj: identity_stub)

      protocol_stub = instance_double('Protocol',
        id: 1,
        type: :protocol_type,
        'valid?' => true)
      expect(protocol_stub).to receive('toggle!').with(:archived)
      stub_find_protocol(protocol_stub)

      xhr :patch, :archive, id: 1, format: :js
    end
  end

  def stub_find_protocol(protocol_stub)
    allow(Protocol).to receive(:find).with(protocol_stub.id.to_s).and_return(protocol_stub)
  end
end
