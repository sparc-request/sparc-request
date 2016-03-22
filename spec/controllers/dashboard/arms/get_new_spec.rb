require 'rails_helper'

RSpec.describe Dashboard::ArmsController do

  describe 'get new' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    let!(:protocol_stub) do
      protocol_stub = instance_double('Protocol', id: 1)
      stub_find_protocol(protocol_stub)
      protocol_stub
    end

    let!(:sr_stub) do
      sr_stub = instance_double('ServiceRequest', id: 2)
      stub_find_service_request(sr_stub)
      sr_stub
    end

    let!(:ssr_stub) do
      ssr_stub = instance_double('SubServiceRequest', id: 3)
      stub_find_sub_service_request(ssr_stub)
      ssr_stub
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
      xhr :get, :new, protocol_id: 1, service_request_id: 2, sub_service_request_id: 3, schedule_tab: 'schedule_tab'
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
      expect(assigns(:arm).protocol_id).to eq(1)
      expect(assigns(:arm)).not_to be_persisted
    end
  end

  def stub_find_protocol(protocol_stub)
    allow(Protocol).to receive(:find).
      with(protocol_stub.id.to_s).
      and_return(protocol_stub)
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
