require 'rails_helper'

RSpec.describe Dashboard::ApprovalsController, type: :controller do
  describe 'GET new' do
    before(:each) do
      @ssr_stub = findable_stub(SubServiceRequest) do
        instance_double(SubServiceRequest, id: 1)
      end

      identity_stub = instance_double('Identity', id: 1)
      log_in_dashboard_identity(obj: identity_stub)
      xhr :get, :new, sub_service_request_id: 1
    end

    it 'should set @sub_service_request to the SubServiceRequest with id params[:sub_service_request_id]' do
      expect(assigns(:sub_service_request)).to eq(@ssr_stub)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/approvals/new" }
  end
end
