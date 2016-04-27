require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "PUT #update" do
    context "params[:fulfillment] describes a valid update" do
      before(:each) do
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:update_attributes).and_return(true)
        stub_find_document(@fulfillment)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        @fulfillment_attrs = "fulfillment attributes"
        xhr :put, :update, id: 1, fulfillment: @fulfillment_attrs
      end

      it "should update document" do
        expect(@fulfillment).to have_received(:update_attributes).
          with(@fulfillment_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:fulfillment] describes an invalid update" do
      before(:each) do
        @fulfillment = instance_double(Fulfillment, id: 1)
        allow(@fulfillment).to receive(:update_attributes).and_return(false)
        allow(@fulfillment).to receive(:errors).and_return("my errors")
        stub_find_document(@fulfillment)

        logged_in_user = create(:identity)
        log_in_dashboard_identity(obj: logged_in_user)

        @fulfillment_attrs = "fulfillment attributes"
        xhr :put, :update, id: 1, fulfillment: @fulfillment_attrs
      end

      it "should attempt to update document" do
        expect(@fulfillment).to have_received(:update_attributes).
          with(@fulfillment_attrs)
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/fulfillments/update" }
      it { is_expected.to respond_with :ok }
    end

    def stub_find_document(obj)
      allow(Fulfillment).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
    end
  end
end
