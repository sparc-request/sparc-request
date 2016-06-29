require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "POST #create" do
    context "params[:fulfillment] describes a valid Fulfillment" do
      before(:each) do
        # stub a Fulfillment#create to return a valid fulfillment
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:valid?).and_return(true)
        allow(Fulfillment).to receive(:new).and_return(@fulfillment)
        allow(@fulfillment).to receive(:save)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :post, :create, fulfillment: "fulfillment attributes"
      end

      it "should create Fulfillment" do
        expect(Fulfillment).to have_received(:new).with("fulfillment attributes")
        expect(@fulfillment).to have_received(:save)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/fulfillments/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:fulfillment] describes an invalid Fulfillment" do
      before(:each) do
        # stub an invalid Fulfillment
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:valid?).and_return(false)
        allow(Fulfillment).to receive(:new).and_return(@fulfillment)
        allow(@fulfillment).to receive(:errors).and_return("my errors")
        allow(@fulfillment).to receive(:save)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :post, :create, fulfillment: "fulfillment attributes"
      end

      it "should attempt to create Fulfillment" do
        expect(Fulfillment).to have_received(:new).with("fulfillment attributes")
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/fulfillments/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
