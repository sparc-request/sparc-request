require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "GET #index" do
    before(:each) do
      @sub_service_request = build_stubbed(:sub_service_request)
      allow(@sub_service_request).to receive(:one_time_fee_line_items).
        and_return("my otf line items")
      stub_find_sub_service_request(@sub_service_request)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
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

    def stub_find_sub_service_request(ssr_stub)
      allow(SubServiceRequest).to receive(:find).
        with(ssr_stub.id.to_s).
        and_return(ssr_stub)
      allow(SubServiceRequest).to receive(:find).
        with(ssr_stub.id).
        and_return(ssr_stub)
    end
  end
end
