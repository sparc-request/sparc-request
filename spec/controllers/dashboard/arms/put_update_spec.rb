require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'PUT update' do
    let!(:identity_stub) { build_stubbed(:identity) }

    let(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    context 'params[:arm] describes a valid update' do
      before(:each) do
        @arm_stub = findable_stub(Arm) { build_stubbed(:arm) }
        allow(@arm_stub).to receive(:update_attributes).and_return(true)

        xhr :put, :update, id: @arm_stub.id, arm: "arm_attributes",
          service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end

      it { is_expected.to render_template "dashboard/arms/update" }
      it { is_expected.to respond_with :ok }

      it 'should set @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(sr_stub)
      end

      it 'should set @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(ssr_stub)
      end

      it 'should assign @arm from params[:arm_id] and update it according to params[:arm]' do
        expect(@arm_stub).to have_received(:update_attributes).with("arm_attributes")
        expect(assigns(:arm)).to eq(@arm_stub)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it "should set flash[:success]" do
        expect(flash[:success]).not_to be_nil
      end
    end

    context 'params[:arm] does not describe a valid update' do
      before(:each) do
        @arm_stub = findable_stub(Arm) do
          instance_double(Arm, id: 1, errors: "uh oh")
        end
        allow(@arm_stub).to receive(:update_attributes).and_return(false)

        xhr :put, :update, id: @arm_stub.id, arm: 'arm_attributes',
          service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end

      it 'should assign @arm from params[:arm_id] and update it according to params[:arm]' do
        expect(@arm_stub).to have_received(:update_attributes).with("arm_attributes")
        expect(assigns(:arm)).to eq(@arm_stub)
      end

      it "should set @errors from invalidated Arm" do
        expect(assigns(:errors)).to eq("uh oh")
      end

      it "should not set flash[:success]" do
        expect(flash[:success]).to be_nil
      end

      it { is_expected.to render_template "dashboard/arms/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
