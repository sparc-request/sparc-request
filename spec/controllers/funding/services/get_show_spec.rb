require 'rails_helper'

RSpec.describe Funding::ServicesController, type: :controller do
  stub_controller
    let!(:before_filters) { find_before_filters }
    let!(:logged_in_user) { create(:identity, ldap_uid: 'john.doe@test.edu') }
    stub_config("funding_admins", ["john.doe@test.edu"])

    let!(:funding_org) { create(:organization)}
    let!(:ids) { [funding_org.id] }

    before :each do
      session[:identity_id] = logged_in_user.id 
      @setting = Setting.find_by_key("funding_org_ids")
      @default_value = @setting.value
      @service = create(:service, :without_validations, organization: funding_org)
    end

  
    describe "#show" do
  
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_funding_admin' do
      expect(before_filters.include?(:authorize_funding_admin)).to eq(true)
    end

    it 'should call before_filter #find_funding_opp' do
      expect(before_filters.include?(:find_funding_opp)).to eq(true)
    end

    it 'should assign @service to the service' do
      @setting.update_attribute(:value, ids.to_s)
      get :show, params: {
        id: @service.id
      }, xhr: true

      expect(assigns(:service)).to eq(@service)
      @setting.update_attribute(:value, @default_value)
    end

    it 'should render template' do
      @setting.update_attribute(:value, ids.to_s)
      get :show, params: {
        id: @service.id
      }, xhr: true

      expect(response).to render_template :show
      @setting.update_attribute(:value, @default_value)
    end
  end
end