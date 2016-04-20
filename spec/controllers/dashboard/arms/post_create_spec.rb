require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'post create' do
    let(:protocol) do
      protocol_stub = instance_double('Protocol',
        id: 1,
        sub_service_requests: SubServiceRequest.none,
        arms: Arm.none)
      stub_find_protocol(protocol_stub)
      protocol_stub
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
      identity_stub = instance_double('Identity', id: 1)
      log_in_dashboard_identity(obj: identity_stub)
    end

    context "params[:arm] does not describe a valid Arm" do
      before(:each) do
        @invalid_arm_stub = instance_double(Arm, valid?: false, errors: "MyErrors")
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, build: nil, arm: @invalid_arm_stub)
        @arm_attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: -1, visit_count: "x" }
        allow(Dashboard::ArmBuilder).to receive(:new).
          and_return(@arm_builder_stub)

        xhr :post, :create, arm: @arm_attrs, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end

      it "should set @errors to invalid Arm's error messages" do
        expect(assigns(:errors)).to eq("MyErrors")
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end

    context "params[:arm] described a valid Arm" do
      before(:each) do
        @valid_arm_stub = instance_double(Arm, valid?: true)
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, build: nil, arm: @valid_arm_stub)
        @arm_attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        allow(Dashboard::ArmBuilder).to receive(:new).
          and_return(@arm_builder_stub)

        xhr :post, :create, arm: @arm_attrs, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end

      it "should use ArmBuilder with params[:arm] to stick new Arm in @selected_arm" do
        expect(Dashboard::ArmBuilder).to have_received(:new).with(@arm_attrs)
        expect(assigns(:selected_arm)).to eq(@valid_arm_stub)
      end

      it 'should assign @protocol from params[:arm][:protocol_id]' do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it 'should assign @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(sr_stub)
      end

      it 'should assign @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(ssr_stub)
      end

      it 'should set flash[:success]' do
        expect(flash[:success]).to eq('Arm Created!')
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end
  end

  def stub_find_arm(arm)
    # allow(Arm).to receive(:find).with(arm.id).and_return(arm)
    allow(Arm).to receive(:find).
      with(arm.id.to_s).
      and_return(arm)
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
