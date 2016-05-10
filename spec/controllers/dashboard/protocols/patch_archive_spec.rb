require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'PATCH #archive' do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
      @protocol_stub = findable_stub(Protocol) do
        build_stubbed(:protocol, type: "Study")
      end
      allow(@protocol_stub).to receive(:valid?).and_return(true)
      allow(@protocol_stub).to receive(:toggle!)

      xhr :patch, :archive, id: @protocol_stub.id
    end

    it 'should toggle archived field of Protocol' do
      expect(@protocol_stub).to have_received(:toggle!).with(:archived)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/protocols/archive" }
  end
end
