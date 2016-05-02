require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'GET navigate' do
    let(:protocol_stub) do
      findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          arms: [instance_double('Arm', id: 2),
                 instance_double('Arm', id: 3)])
      end
    end

    let(:arm_stub) do
      findable_stub(Arm) { instance_double(Arm, id: 1) }
    end

    let(:sr_stub) do
      findable_stub(ServiceRequest) { instance_double(ServiceRequest, id: 2) }
    end

    let(:ssr_stub) do
      findable_stub(SubServiceRequest) { instance_double(SubServiceRequest, id: 3) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: instance_double(Identity, id: 1))
    end

    context 'params[:arm_id] present' do
      before(:each) do
        xhr :get, :navigate, protocol_id: protocol_stub.id, arm_id: arm_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
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

      it 'should set @intended_action to params[:intended_action]' do
        expect(assigns(:intended_action)).to eq('chillax')
      end

      it 'should set @arm from params[:arm_id]' do
        expect(assigns(:arm)).to eq(arm_stub)
      end

      it { is_expected.to render_template "dashboard/arms/navigate" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:arm_id] absent' do
      before(:each) do
        xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
      end

      it 'should set @arm to the Protocol\'s first Arm' do
        expect(assigns(:arm)).to eq(protocol_stub.arms.first)
      end

      it { is_expected.to render_template "dashboard/arms/navigate" }
      it { is_expected.to respond_with :ok }
    end
  end
end
