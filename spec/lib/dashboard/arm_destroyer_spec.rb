require "rails_helper"

RSpec.describe Dashboard::ArmDestroyer do
  describe "#destroy" do
    context "Arm only Arm for ServiceRequest" do
      before(:each) do
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        # build out a Protocol with PPPV LineItems, one Arm
        protocol = create(:protocol_without_validations)
        arm = create(:arm, :without_validations, protocol: protocol)
        service_request = create(:service_request_without_validations, protocol: protocol)
        sub_service_request = create(:sub_service_request, :without_validations, service_request: service_request)
        pppv_service = create(:service, :without_validations, one_time_fee: false)
        @pppv_line_item = create(:line_item, :without_validations, service: pppv_service, service_request: service_request)
        otf_service = create(:service, :without_validations, one_time_fee: true)
        @otf_line_item = create(:line_item, :without_validations, service: otf_service, service_request: service_request)

        @destroyer = Dashboard::ArmDestroyer.new(id: arm.id, sub_service_request_id: sub_service_request.id)
        @destroyer.destroy
      end

      it "should delete each PPPV LineItem belonging to ServiceRequest" do
        expect { @pppv_line_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { @otf_line_item.reload }.not_to raise_error
      end

      it "should not set @selected_arm" do
        expect(@destroyer.selected_arm).to be_nil
      end
    end

    context "Arm not only Arm for ServiceRequest" do
      before(:each) do
        SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
        # build out a Protocol with PPPV LineItems, one Arm
        protocol = create(:protocol_without_validations)
        arm1 = create(:arm, :without_validations, protocol: protocol)
        @arm2 = create(:arm, :without_validations, protocol: protocol)
        service_request = create(:service_request_without_validations, protocol: protocol)
        sub_service_request = create(:sub_service_request, :without_validations, service_request: service_request)
        pppv_service = create(:service, :without_validations, one_time_fee: false)
        @pppv_line_item = create(:line_item, :without_validations, service: pppv_service, service_request: service_request)
        otf_service = create(:service, :without_validations, one_time_fee: true)
        @otf_line_item = create(:line_item, :without_validations, service: otf_service, service_request: service_request)

        @destroyer = Dashboard::ArmDestroyer.new(id: arm1.id, sub_service_request_id: sub_service_request.id)
        @destroyer.destroy
      end

      it "should not delete any LineItems belonging to ServiceRequest" do
        expect { @pppv_line_item.reload }.not_to raise_error
        expect { @otf_line_item.reload }.not_to raise_error
      end

      it "should set @selected_arm" do
        expect(@destroyer.selected_arm).to eq(@arm2)
      end
    end
  end

  # these attribute accessors should be nil until #destroy invoked
  describe "#sub_service_request" do
    before(:each) do
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
      # build out a Protocol with PPPV LineItems, one Arm
      protocol = create(:protocol_without_validations)
      arm = create(:arm, :without_validations, protocol: protocol)
      service_request = create(:service_request_without_validations, protocol: protocol)
      @sub_service_request = create(:sub_service_request, :without_validations, service_request: service_request)
      pppv_service = create(:service, :without_validations, one_time_fee: false)
      @pppv_line_item = create(:line_item, :without_validations, service: pppv_service, service_request: service_request)
      otf_service = create(:service, :without_validations, one_time_fee: true)
      @otf_line_item = create(:line_item, :without_validations, service: otf_service, service_request: service_request)

      @destroyer = Dashboard::ArmDestroyer.new(id: arm.id, sub_service_request_id: @sub_service_request.id)
    end

    context "before #destroy invoked" do
      it "should be nil before #destroy invoked" do
        expect(@destroyer.sub_service_request).to be_nil
      end
    end

    context "after #destroy invoked" do
      it "should be SubServiceRequest described by params[:sub_service_request_id] after #destroy invoked" do
        @destroyer.destroy
        expect(@destroyer.sub_service_request).to eq(@sub_service_request)
      end
    end
  end

  describe "#service_request" do
    before(:each) do
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
      # build out a Protocol with PPPV LineItems, one Arm
      protocol = create(:protocol_without_validations)
      arm = create(:arm, :without_validations, protocol: protocol)
      @service_request = create(:service_request_without_validations, protocol: protocol)
      sub_service_request = create(:sub_service_request, :without_validations, service_request: @service_request)
      pppv_service = create(:service, :without_validations, one_time_fee: false)
      @pppv_line_item = create(:line_item, :without_validations, service: pppv_service, service_request: @service_request)
      otf_service = create(:service, :without_validations, one_time_fee: true)
      @otf_line_item = create(:line_item, :without_validations, service: otf_service, service_request: @service_request)

      @destroyer = Dashboard::ArmDestroyer.new(id: arm.id, sub_service_request_id: sub_service_request.id)
    end

    context "before #destroy invoked" do
      it "should be nil before #destroy invoked" do
        expect(@destroyer.service_request).to be_nil
      end
    end

    context "after #destroy invoked" do
      before(:each) { @destroyer.destroy }

      it "should be ServiceRequest of Arm described by params[:id] after #destroy invoked" do
        expect(@destroyer.service_request).to eq(@service_request)
      end

      it "should not be associated with deleted Arm" do
        expect(@destroyer.service_request.arms).to be_empty
      end
    end
  end
end
