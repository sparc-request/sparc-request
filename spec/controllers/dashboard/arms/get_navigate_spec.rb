require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'get navigate' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    let(:protocol_stub) do
      protocol = instance_double('Protocol',
        id: 1,
        arms: [
          instance_double('Arm', id: 2),
          instance_double('Arm', id: 3)
          ])
      stub_find_protocol(protocol)
      protocol
    end

    let(:arm_stub) do
      obj = instance_double('Arm', id: 1)
      stub_find_arm(obj)
      obj
    end

    let(:sr_stub) do
      obj = instance_double('ServiceRequest', id: 2)
      stub_find_service_request(obj)
      obj
    end

    let(:ssr_stub) do
      obj = instance_double('SubServiceRequest', id: 3)
      stub_find_sub_service_request(obj)
      obj
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    it 'should set @protocol from params[:protocol_id]' do
      xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      expect(assigns(:protocol)).to eq(protocol_stub)
    end

    it 'should set @service_request from params[:service_request_id]' do
      xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      expect(assigns(:service_request)).to eq(sr_stub)
    end

    it 'should set @sub_service_request from params[:sub_service_request_id]' do
      xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      expect(assigns(:sub_service_request)).to eq(ssr_stub)
    end

    it 'should set @intended_action to params[:intended_action]' do
      xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
      expect(assigns(:intended_action)).to eq('chillax')
    end

    context 'params[:arm_id] present' do
      it 'should set @arm from params[:arm_id]' do
        xhr :get, :navigate, arm_id: arm_stub.id, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
        expect(assigns(:arm)).to eq(arm_stub)
      end
    end

    context 'params[:arm_id] absent' do
      it 'should set @arm to the Protocol\'s first Arm' do
        xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
        expect(assigns(:arm)).to eq(protocol_stub.arms.first)
      end
    end
  end

  def stub_find_arm(arm)
    allow(Arm).to receive(:find).with(arm.id).and_return(arm)
    allow(Arm).to receive(:find).with(arm.id.to_s).and_return(arm)
  end

  def stub_find_protocol(protocol)
    allow(Protocol).to receive(:find).
      with(protocol.id.to_s).
      and_return(protocol)
  end

  def stub_find_service_request(sr_stub)
    allow(ServiceRequest).to receive(:find).
      with(sr_stub.id.to_s).
      and_return(sr_stub)
  end

  def stub_find_sub_service_request(ssr_stub)
    allow(SubServiceRequest).to receive(:find).
      with(ssr_stub.id.to_s).
      and_return(ssr_stub)
  end
end
