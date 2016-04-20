require 'rails_helper'

RSpec.describe Dashboard::ApprovalsController, type: :controller do
  describe 'GET new' do
    before(:each) do
      identity_stub = instance_double('Identity', id: 1)
      log_in_dashboard_identity(obj: identity_stub)
      @ssr_stub = instance_double('SubServiceRequest', id: 1)
      stub_find_sub_service_request(@ssr_stub)

      xhr :get, :new, sub_service_request_id: 1
    end

    it 'should set @sub_service_request to the SubServiceRequest with id params[:sub_service_request_id]' do
      expect(assigns(:sub_service_request)).to eq(@ssr_stub)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/approvals/new" }
  end

  def stub_find_sub_service_request(ssr_stub)
    allow(SubServiceRequest).to receive(:find).with(ssr_stub.id.to_s).and_return(ssr_stub)
  end
end
