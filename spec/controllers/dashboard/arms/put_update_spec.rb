require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'put update' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

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

    it 'should set @service_request from params[:service_request_id]' do
      allow(arm_stub).to receive(:update_attributes).and_return(true)

      xhr :put, :update, id: arm_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:service_request)).to eq(sr_stub)
    end

    it 'should set @sub_service_request from params[:sub_service_request_id]' do
      allow(arm_stub).to receive(:update_attributes).and_return(true)

      xhr :put, :update, id: arm_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:sub_service_request)).to eq(ssr_stub)
    end

    context 'params[:arm] describes a valid update' do
      it 'should assign @arm from params[:arm_id] and update it according to params[:arm]' do
        expect(arm_stub).to receive(:update_attributes).
          with('arm_attributes').and_return(true)

        xhr :put, :update, id: arm_stub.id, arm: 'arm_attributes', service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

        expect(assigns(:arm)).to eq(arm_stub)
        expect(assigns(:errors)).to be_nil
      end
    end

    context 'params[:arm] does not describe a valid update' do
      it 'should assign @arm from params[:arm_id] and set @errors to @arm\'s errors attribute' do
        expect(arm_stub).to receive(:update_attributes).
          with('arm_attributes').and_return(false)
        expect(arm_stub).to receive(:errors).and_return('uh oh')
        xhr :put, :update, id: arm_stub.id, arm: 'arm_attributes', service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

        expect(assigns(:arm)).to eq(arm_stub)
        expect(assigns(:errors)).to eq('uh oh')
      end
    end
  end

  def stub_find_arm(arm)
    allow(Arm).to receive(:find).with(arm.id).and_return(arm)
    allow(Arm).to receive(:find).with(arm.id.to_s).and_return(arm)
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
