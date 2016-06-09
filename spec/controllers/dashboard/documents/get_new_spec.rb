require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "GET #new" do
    before(:each) do
      @document = findable_stub(Document) { build_stubbed(:document) }
      @sub_service_request = findable_stub(SubServiceRequest) do
        build_stubbed(:sub_service_request)
      end
      allow(@sub_service_request).to receive(:documents).and_return(@documents)

      logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: logged_in_user)

      xhr :get, :edit, id: @document.id, sub_service_request_id: @sub_service_request.id
    end

    it "should assign @sub_service_request from params[:sub_service_request]" do
      expect(assigns(:sub_service_request)).to eq(@sub_service_request)
    end

    it "should assign @document from params[:id]" do
      expect(assigns(:document)).to eq(@document)
    end

    it "should assign @header_text" do
      expect(assigns(:header_text)).to be_present
    end

    it { is_expected.to render_template "dashboard/documents/edit" }
    it { is_expected.to respond_with :ok }
  end
end
