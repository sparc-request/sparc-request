require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "GET #edit" do
    before(:each) do
      @sub_service_request = build_stubbed(:sub_service_request)
      stub_find_sub_service_request(@sub_service_request)

      @document = build_stubbed(:document)
      stub_find_document(@document)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      xhr :get, :edit, id: @document.id, sub_service_request_id: @sub_service_request.id
    end

    it "should set @document from params[:id]" do
      expect(assigns(:document)).to eq(@document)
    end

    it "should set @sub_service_request from params[:sub_service_request_id]" do
      expect(assigns(:sub_service_request)).to eq(@sub_service_request)
    end

    it "should set @header_text" do
      expect(assigns(:header_text)).not_to be_nil
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/documents/edit" }
  end

  def stub_find_sub_service_request(obj)
    allow(SubServiceRequest).to receive(:find).
      with(obj.id.to_s).
      and_return(obj)
  end

  def stub_find_document(obj)
    allow(Document).to receive(:find).
      with(obj.id.to_s).
      and_return(obj)
  end
end
