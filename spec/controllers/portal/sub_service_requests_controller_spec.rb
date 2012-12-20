require 'spec_helper'

describe Portal::SubServiceRequestsController do
  stub_portal_controller

  describe 'add_line_item' do
    let!(:core)                 { FactoryGirl.create(:core) }
    let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/javascript" 
    end

    it 'should work (smoke test)' do
      service_request = FactoryGirl.create(
          :service_request,
          subject_count: 5,
          visit_count:   5)
      sub_service_request = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request.id,
          organization_id:    core.id)

      post(
          :add_line_item,
          :id              => sub_service_request.id,
          :new_service_id  => service.id)

      service_request.reload
      service_request.line_items.count.should eq 1
      service_request.line_items[0].quantity.should eq nil
      service_request.line_items[0].visits.count.should eq 5
    end

    it 'should work when the service request visit count is nil' do
      service_request = FactoryGirl.create(
          :service_request,
          subject_count: 5,
          visit_count:   nil)
      sub_service_request = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request.id,
          organization_id:    core.id)

      post(
          :add_line_item,
          :id              => sub_service_request.id,
          :new_service_id  => service.id)

      service_request.reload
      service_request.line_items.reload
      service_request.line_items.count.should eq 1
      service_request.line_items[0].quantity.should eq nil
      service_request.line_items[0].visits.count.should eq 1
    end
  end
end

