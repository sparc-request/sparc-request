require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "GET #edit" do
    before(:each) do
      @fulfillment = findable_stub(Fulfillment) do
        instance_double(Fulfillment, id: 1)
      end

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      xhr :get, :edit, id: 1
    end

    it "should assign @fulfillment from params[:id]" do
      expect(assigns(:fulfillment)).to eq(@fulfillment)
    end

    it "should assign @header_text" do
      expect(assigns(:header_text)).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/fulfillments/edit" }
    it { is_expected.to respond_with :ok }
  end
end
