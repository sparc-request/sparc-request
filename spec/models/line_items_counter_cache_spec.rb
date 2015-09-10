require 'rails_helper'

RSpec.describe "Line items counter cache" do

  let!(:new_service) { create(:service, name: "New Service") }
  let!(:service_request) { FactoryGirl.create(:service_request_without_validations) }

  describe "creating line items" do

    it "should increase the count of the cache when a line item is created" do
      line_item = create(:line_item, service_id: new_service.id, service_request_id: service_request.id)
      expect(line_item.reload.service.line_items_count).to eq(1)
    end
  end

  describe "destroying line items" do

    it "should decrease the count of the cache when a line item is destroyed" do
      line_item = create(:line_item, service_id: new_service.id, service_request_id: service_request.id)
      expect(line_item.reload.service.line_items_count).to eq(1)
      line_item.destroy
      expect(new_service.line_items_count).to eq(0)
    end
  end
end
