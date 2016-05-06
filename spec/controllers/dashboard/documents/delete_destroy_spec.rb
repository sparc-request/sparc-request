require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "DELETE #destroy" do
    before(:each) do
      allow(Dashboard::DocumentRemover).to receive(:new)

      logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      xhr :delete, :destroy, id: "document_id",
        sub_service_request_id: "sub_service_request_id"
    end

    it "should destroy the Document <- params[:id] from the SubServiceRequest <- params[:sub_service_request_id] using Dashboard::DocumentRemover" do
      expect(Dashboard::DocumentRemover).to have_received(:new).
        with(id: "document_id", sub_service_request_id: "sub_service_request_id")
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/documents/destroy" }
  end
end
