require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "GET #new" do
    before(:each) do
      @fulfillment = instance_double(Fulfillment)
      allow(Fulfillment).to receive(:new).
        with(line_item_id: "100").
        and_return(@fulfillment)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      xhr :get, :new, line_item_id: 100
    end

    it "should assign to @fulfillment a new Fulfillment associated with LineItem from params[:line_item_id]" do
      expect(assigns(:fulfillment)).to eq(@fulfillment)
    end

    it "should assign @header_text" do
      expect(assigns(:header_text)).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/fulfillments/new" }
    it { is_expected.to respond_with :ok }
  end
end
