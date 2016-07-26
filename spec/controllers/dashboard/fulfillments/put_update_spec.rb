require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "PUT #update" do
    context "params[:fulfillment] describes a valid update" do
      before(:each) do
        @fulfillment = findable_stub(Fulfillment) do
          instance_double(Fulfillment, id: 1)
        end
        allow(@fulfillment).to receive(:update_attributes).and_return(true)
        allow(@fulfillment).to receive(:line_item)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :put, :update, id: @fulfillment.id, fulfillment: "fulfillment attributes"
      end

      it "should update Fulfillment" do
        expect(@fulfillment).to have_received(:update_attributes).
          with("fulfillment attributes")
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:fulfillment] describes an invalid update" do
      before(:each) do
        @fulfillment = findable_stub(Fulfillment) do
          instance_double(Fulfillment, id: 1)
        end
        allow(@fulfillment).to receive(:update_attributes).and_return(false)
        allow(@fulfillment).to receive(:line_item)
        allow(@fulfillment).to receive(:errors).and_return("my errors")

        logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        xhr :put, :update, id: @fulfillment.id, fulfillment: "fulfillment attributes"
      end

      it "should attempt to update Fulfillment" do
        expect(@fulfillment).to have_received(:update_attributes).
          with("fulfillment attributes")
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
