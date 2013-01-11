require 'spec_helper'

describe Portal::ServicesController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service) {
    service = FactoryGirl.create(
        :service,
        organization: core,
        pricing_map_count: 1)
    service.pricing_maps[0].display_date = Date.today
    service
  }

  # TODO: this test is disabled since the method does not work
  #
  # describe 'GET show' do
  #   it 'should set service' do
  #     get :show, {
  #       format: :js,
  #       id: service.id,
  #       service_id: 'foo',
  #       status: 'bar',
  #     }.with_indifferent_access
  #
  #     assigns(:service).should eq service
  #   end
  # end
end
