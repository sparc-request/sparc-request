require "spec_helper"

RSpec.describe Dashboard::ArmDestroyer do
  describe "#destroy" do
    context "Arm only Arm for ServiceRequest" do
      it "should delete each PPPV LineItem belonging to ServiceRequest" do

      end

      it "should not set @selected_arm" do

      end
    end

    context "Arm not only Arm for ServiceRequest" do
      it "should not delete each PPPV LineItem belonging to ServiceRequest" do

      end

      it "should set @selected_arm" do

      end
    end
  end

  # these attribute accessors should be nil until #destroy invoked
  describe "#sub_service_request" do
    context "before #destroy invoked" do
      it "should be nil before #destroy invoked" do

      end
    end

    context "after #destroy invoked" do
      it "should be SubServiceRequest described by params[:sub_service_request_id] after #destroy invoked" do

      end
    end
  end

  describe "#service_request" do
    context "before #destroy invoked" do
      it "should be nil before #destroy invoked" do

      end
    end

    context "after #destroy invoked" do
      it "should be ServiceRequest of Arm described by params[:id] after #destroy invoked" do

      end

      it "should not be associated with deleted Arm" do
        
      end
    end
  end
end
