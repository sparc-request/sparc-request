require 'spec_helper'

describe "Line items counter cache" do

  let!(:new_service) { FactoryGirl.create(:service, name: "New Service") }
  let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }

  describe "creating line items" do

    it "should increase the count of the cache when a line item is created" do
      line_item = FactoryGirl.create(:line_item, service_id: new_service.id, service_request_id: service_request.id)
      line_item.reload.service.line_items_count.should eq(1)
    end
  end

  describe "destroying line items" do

    it "should decrease the count of the cache when a line item is destroyed" do
      line_item = FactoryGirl.create(:line_item, service_id: new_service.id, service_request_id: service_request.id)
      line_item.reload.service.line_items_count.should eq(1)
      line_item.destroy
      new_service.line_items_count.should eq(0)
    end
  end
end