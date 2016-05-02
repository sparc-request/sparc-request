require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "GET #index" do
    before(:each) do
      @documents = instance_double(ActiveRecord::Relation)
      sub_service_request = build_stubbed(:sub_service_request)
      allow(sub_service_request).to receive(:documents).and_return(@documents)
      stub_find_sub_service_request(sub_service_request)

      logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      get :index, sub_service_request_id: sub_service_request.id, format: :json
    end

    it "should set @documents to Documents of SubServiceRequest from params[:sub_service_request_id]" do
      expect(assigns(:documents)).to eq(@documents)
    end

    it { is_expected.to render_template "dashboard/documents/index" }
    it { is_expected.to respond_with :ok }

    def stub_find_sub_service_request(obj)
      allow(SubServiceRequest).to receive(:find).
        with(obj.id).
        and_return(obj)
    end
  end
end
