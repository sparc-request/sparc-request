require 'rails_helper'

RSpec.describe Dashboard::ApprovalsController, type: :controller do
  describe 'GET new' do
    before(:each) do
      @ssr_stub = findable_stub(SubServiceRequest) do
        build_stubbed(SubServiceRequest)
      end

      log_in_dashboard_identity(obj: build_stubbed(:identity))
      xhr :get, :new, ssr_id: @ssr_stub.id
    end

    it 'should set @sub_service_request to the SubServiceRequest with id params[:ssr_id]' do
      expect(assigns(:sub_service_request)).to eq(@ssr_stub)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/approvals/new" }
  end
end
