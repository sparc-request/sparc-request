require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'post create' do
    let(:protocol) do
      findable_stub(Protocol) { build_stubbed(:protocol) }
    end

    let(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
    end

    context "params[:arm] does not describe a valid Arm" do
      before(:each) do
        @invalid_arm_stub = instance_double(Arm, valid?: false, errors: "MyErrors")
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, arm: @invalid_arm_stub)
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
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, arm: @valid_arm_stub)
        @arm_attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        allow(Dashboard::ArmBuilder).to receive(:new).
          and_return(@arm_builder_stub)

        xhr :post, :create, arm: @arm_attrs, service_request_id: sr_stub.id,
          sub_service_request_id: ssr_stub.id
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
end
