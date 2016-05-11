require 'rails_helper'

RSpec.describe Dashboard::ArmsController do
  describe 'delete destroy' do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))

      @request_params = { id: "arm id", sub_service_request_id: "sub service request id" }
      @destroyer = instance_double(Dashboard::ArmDestroyer,
        service_request: "service request",
        sub_service_request: "sub service request",
        selected_arm: "selected arm")
      allow(@destroyer).to receive(:destroy)
      allow(Dashboard::ArmDestroyer).to receive(:new).
        and_return(@destroyer)

      xhr :delete, :destroy, @request_params
    end

    it "should use Dashboard::ArmDestroyer" do
      expect(Dashboard::ArmDestroyer).to have_received(:new).
        with(id: "arm id", sub_service_request_id: "sub service request id")
    end

    it "should invoke #destroy on Dashboard::ArmDestroyer" do
      expect(@destroyer).to have_received(:destroy)
    end

    it "should assign @service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:service_request)).to eq("service request")
    end

    it "should assign @sub_service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:sub_service_request)).to eq("sub service request")
    end

    it "should assign @selected_arm from Dashboard::ArmDestroyer instance" do
      expect(assigns(:selected_arm)).to eq("selected arm")
    end

    it "should set flash[:alert]" do
      expect(flash[:alert]).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/arms/destroy" }

    it { is_expected.to respond_with :ok }
  end
end
