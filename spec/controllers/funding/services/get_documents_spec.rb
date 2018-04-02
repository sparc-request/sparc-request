require 'rails_helper'

RSpec.describe Funding::ServicesController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity, ldap_uid: 'john.doe@test.edu') }
  stub_config("funding_admins", ["john.doe@test.edu"])
 
  describe "#documents" do
    before :each do
      session[:identity_id] = logged_in_user.id
      get :documents, params: {id: "Service id", table: "doc_type", format: :json}
    end

    it "should assign @table to params[:table]" do
      expect(assigns(:table)).to eq("doc_type")
    end

    it "should assign @id from params[:id]" do
      expect(assigns(:service_id)).to eq("Service id")
    end

    it { is_expected.to render_template "funding/services/documents" }
    it { is_expected.to respond_with :ok }
  end
end