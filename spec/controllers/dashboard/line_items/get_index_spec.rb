require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "GET #index" do
    before(:each) do
      @sub_service_request = findable_stub(SubServiceRequest) do
        build_stubbed(:sub_service_request)
      end
      allow(@sub_service_request).to receive(:one_time_fee_line_items).
        and_return("my otf line items")

      log_in_dashboard_identity(obj: build_stubbed(:identity))
      get :index, sub_service_request_id: @sub_service_request.id, format: :json
    end

    it "should assign @sub_service_request from params[:sub_service_request_id]" do
      expect(assigns(:sub_service_request)).to eq(@sub_service_request)
    end

    it "should assign @line_items from one time fee LineItems of SubServiceRequest" do
      expect(assigns(:line_items)).to eq("my otf line items")
    end

    it { is_expected.to render_template "dashboard/line_items/index" }
    it { is_expected.to respond_with :ok }
  end
end
