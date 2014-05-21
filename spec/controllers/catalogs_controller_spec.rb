require 'spec_helper'

describe CatalogsController do
  stub_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }

  describe 'POST update_description' do
    it 'should set organization and service_request' do
      session[:service_request_id] = service_request.id
      get :update_description, {
        :format              => :js,
        :id                  => core.id,
        :service_request_id  => service_request.id,
      }.with_indifferent_access
      assigns(:organization).should eq core
      assigns(:service_request).should eq service_request
    end
  end
end

