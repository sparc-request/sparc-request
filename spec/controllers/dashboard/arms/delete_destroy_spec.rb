require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'delete destroy' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
      arm_destroyer_stub = instance_double(Dashboard::ArmDestroyer,
        service_request: "ServiceRequest",
        sub_service_request: "SubServiceRequest")
      allow(Dashboard::ArmDestroyer).to receive(:new).and_return(arm_destroyer_stub)
      request_params = id: arm_stub.id, sub_service_request_id: ssr_stub.id

      xhr :delete, :destroy, request_params
    end

    it "should use Dashboard::ArmDestroyer" do
      expect(Dashboard::ArmDestroyer).to have_received(:new).with(request_params)
    end

    it "should assign @service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:service_request)).to eq("ServiceRequest")
    end

    it "should assign @sub_service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:sub_service_request)).to eq("SubServiceRequest")
    end

    it "should set flash[:alert]" do
      expect(flash[:alert]).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/arms/destroy" }

    it { is_expected.to respond_with :ok }


    after(:each) { expect(arm_stub).to have_received(:destroy) }

    it 'should set @sub_service_request from params[:sub_service_request_id]' do
      allow(sr_stub).to receive(:reload)
      allow(sr_stub).to receive(:arms).and_return([:last_arm])

      xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:sub_service_request)).to eq(ssr_stub)
    end

    it 'should set @service_request to the SubServiceRequest\'s ServiceRequest' do
      allow(sr_stub).to receive(:reload)
      allow(sr_stub).to receive(:arms).and_return([:last_arm])

      xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id

      expect(assigns(:service_request)).to eq(ssr_stub.service_request)
    end

    it 'should delete Arm' do
      allow(sr_stub).to receive(:reload)
      allow(sr_stub).to receive(:arms).and_return([:last_arm])

      xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id
    end

    it 'should set flash[:alert]' do
      allow(sr_stub).to receive(:reload)
      allow(sr_stub).to receive(:arms).and_return([:last_arm])

      xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id

      expect(flash[:alert]).to eq('Arm Destroyed!')
    end

    context 'deleting ServiceRequest\'s last Arm' do
      it 'should destroy each PPPV LineItem on the ServiceRequest' do
        allow(sr_stub).to receive(:arms).and_return([arm_stub])

        allow(sr_stub).to receive(:reload) do
          allow(sr_stub).to receive(:arms).and_return([])
        end

        pppv_li = instance_double('LineItem')
        expect(pppv_li).to receive(:destroy)
        allow(sr_stub).to receive(:per_patient_per_visit_line_items).and_return([pppv_li])

        xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id
      end
    end

    context 'not deleting ServiceRequest\'s last Arm' do
      it 'should set @selected_arm to ServiceRequest\'s first Arm (after deletion)' do
        allow(sr_stub).to receive(:arms).and_return([arm_stub])

        allow(sr_stub).to receive(:reload)  # do
        #   allow(sr_stub).to receive(:arms).and_return([])       keep Arm around to match context
        # end

        pppv_li = instance_double('LineItem')
        expect(pppv_li).not_to receive(:destroy)
        allow(sr_stub).to receive(:per_patient_per_visit_line_items).and_return([pppv_li])

        xhr :delete, :destroy, id: arm_stub.id, sub_service_request_id: ssr_stub.id
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
