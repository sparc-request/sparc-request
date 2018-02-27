require 'rails_helper'

RSpec.describe Funding::ServicesController, type: :controller do
  stub_controller
    let!(:before_filters) { find_before_filters }
    let!(:logged_in_user) { create(:identity, ldap_uid: 'john.doe@test.edu') }
    stub_config("funding_admins", ["john.doe@test.edu"])

    before :each do
      session[:identity_id] = logged_in_user.id
    end
  
    describe "#index" do
  
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should call before_filter #authorize_funding_admin' do
      expect(before_filters.include?(:authorize_funding_admin)).to eq(true)
    end

    context 'when format html' do
      it 'should render template' do
        get :index, params: {
          format: :html
        }, xhr: true

        expect(controller).to render_template(:index)
      end

      it 'should respond ok' do
        get :index, params: {
          format: :html
        }, xhr: true

        expect(controller).to respond_with(:ok)
      end
    end

    context 'when format json' do
      it 'should assign @services to funding opportunities' do
        funding_org = build_stubbed(:organization)
        setting = Setting.find_by_key("funding_org_ids")
        default_value = setting.value
        setting.update_attribute(:value, [ funding_org.id ].to_s)
        service = create(:service, :without_validations, organization: funding_org)

        get :index, params: {
          format: :json
        }, xhr: true

        expect(assigns(:services)).to eq(Service.funding_opportunities)
        setting.update_attribute(:value, default_value)
      end

      it 'should render template' do
        get :index, params: {
          format: :json
        }, xhr: true

        expect(controller).to render_template(:index)
      end

      it 'should respond ok' do
        get :index, params: {
          format: :json
        }, xhr: true

        expect(controller).to respond_with(:ok)
      end
    end
  end
end