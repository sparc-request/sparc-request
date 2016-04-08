require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'post create' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    def protocol_stub(opts = {})
      protocol = instance_double('Protocol',
        id: 1,
        sub_service_requests: opts[:sub_service_requests] || SubServiceRequest.none,
        arms: opts[:arms] || Arm.none)
      stub_find_protocol(protocol)
      protocol
    end

    def arm_stub(valid = true)
      instance_double('Arm',
        default_visit_days: true,
        reload: true,
        populate_subjects: true,
        :valid? => valid)
    end

    let(:sr_stub) do
      sr_stub = instance_double('ServiceRequest', id: 2)
      stub_find_service_request(sr_stub)
      sr_stub
    end

    let(:ssr_stub) do
      ssr_stub = instance_double('SubServiceRequest', id: 3)
      stub_find_sub_service_request(ssr_stub)
      ssr_stub
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    context 'Protocol has SubServiceRequests in CWF' do
      it 'should populate subjects for new Arm' do
        # stub collection of SubServiceRequests + in_work_fulfillment scope
        sub_service_requests_collection = double(ActiveRecord::Relation)
        expect(sub_service_requests_collection).
            to receive_message_chain(:in_work_fulfillment, :any?).
                and_return(true)
        protocol = protocol_stub(sub_service_requests: sub_service_requests_collection)
        allow(protocol).to receive_message_chain(:sub_service_requests, :in_work_fulfillment, :any?).and_return(true)
        arm = arm_stub()
        expect(arm).to receive(:populate_subjects)
        expect(protocol).to receive(:create_arm).and_return(arm)

        xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end
    end

    context 'Protocol has no SubServiceRequests in CWF' do
      it 'should not populate subjects for new Arm' do
        # stub collection of SubServiceRequests + in_work_fulfillment scope
        sub_service_requests_collection = double(ActiveRecord::Relation)
        expect(sub_service_requests_collection).
            to receive_message_chain(:in_work_fulfillment, :any?).
                and_return(false)
        protocol = protocol_stub(sub_service_requests: sub_service_requests_collection)
        arm = arm_stub()
        expect(arm).not_to receive(:populate_subjects)
        expect(protocol).to receive(:create_arm).and_return(arm)

        xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end
    end

    it 'should assign @protocol from params[:arm][:protocol_id]' do
      protocol = protocol_stub()
      expect(protocol).to receive(:create_arm).and_return(arm_stub())

      xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:protocol)).to eq(protocol)
    end

    it 'should assign @service_request from params[:service_request_id]' do
      protocol = protocol_stub()
      expect(protocol).to receive(:create_arm).and_return(arm_stub())

      xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:service_request)).to eq(sr_stub)
    end

    it 'should assign @sub_service_request from params[:sub_service_request_id]' do
      protocol = protocol_stub()
      expect(protocol).to receive(:create_arm).and_return(arm_stub())

      xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:sub_service_request)).to eq(ssr_stub)
    end

    it 'should assign @selected_arm to a new Arm described by params[:arm]' do
      protocol = protocol_stub()
      arm = arm_stub()
      arm_params = { protocol_id: protocol.id, name: 'arbitrary name', visit_count: '2', subject_count: '3' }
      expect(protocol).to receive(:create_arm).with({ name: 'arbitrary name', visit_count: 2, subject_count: 3 }).and_return(arm)

      xhr :post, :create, arm: arm_params, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:selected_arm)).to eq(arm)
    end

    it 'should set default visit days for new Arm and reload it' do
      protocol = protocol_stub()
      arm = arm_stub()
      expect(arm).to receive(:default_visit_days)
      expect(arm).to receive(:reload)
      expect(protocol).to receive(:create_arm).and_return(arm)

      xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
    end

    it 'should set flash[:success]' do
      protocol = protocol_stub()
      arm = arm_stub()
      expect(protocol).to receive(:create_arm).and_return(arm)

      xhr :post, :create, arm: { protocol_id: protocol.id }, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id

      expect(flash[:success]).to eq('Arm Created!')
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
