require "rails_helper"

RSpec.describe Dashboard::DocumentsController do
  describe "GET #index" do
    before(:each) do
      @documents = instance_double(ActiveRecord::Relation)
      sub_service_request = findable_stub(SubServiceRequest) do
        build_stubbed(:sub_service_request)
      end
      allow(sub_service_request).to receive(:documents).and_return(@documents)

      logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: logged_in_user)
      get :index, sub_service_request_id: sub_service_request.id, format: :json
    end

    it "should set @documents to Documents of SubServiceRequest from params[:sub_service_request_id]" do
      expect(assigns(:documents)).to eq(@documents)
    end

    it { is_expected.to render_template "dashboard/documents/index" }
    it { is_expected.to respond_with :ok }
  end
end
