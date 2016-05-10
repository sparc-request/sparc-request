require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'GET new' do
    let!(:identity_stub) { build_stubbed(:identity) }

    let!(:protocol_stub) do
      findable_stub(Protocol) { build_stubbed(:protocol) }
    end

    let!(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let!(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
      xhr :get, :new, protocol_id: protocol_stub.id, service_request_id: sr_stub.id,
        sub_service_request_id: ssr_stub.id, schedule_tab: 'schedule_tab'
    end

    it 'should set @protocol from params[:protocol_id]' do
      expect(assigns(:protocol)).to eq(protocol_stub)
    end

    it 'should set @service_request from params[:service_request_id]' do
      expect(assigns(:service_request)).to eq(sr_stub)
    end

    it 'should set @sub_service_request from params[:sub_service_request_id]' do
      expect(assigns(:sub_service_request)).to eq(ssr_stub)
    end

    it 'should set @schedule_tab from params[:schedule_tab]' do
      expect(assigns(:schedule_tab)).to eq('schedule_tab')
    end

    it 'should assign @arm to a new, unpersisted Arm associated with Protocol' do
      expect(assigns(:arm).protocol_id).to eq(protocol_stub.id)
      expect(assigns(:arm)).not_to be_persisted
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/arms/new" }
  end
end
