require 'rails_helper'

RSpec.describe 'Visit' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  let!(:arm)               { create(:arm) }
  let!(:line_items_visit1) { create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id) }
  let!(:visit_group)       { create(:visit_group, arm_id: arm.id)}
  let!(:visit1)            { create(:visit, line_items_visit_id: line_items_visit1.id, visit_group_id: visit_group.id) }

  describe 'quantities customized' do

    it 'should return false if the quantities are untouched, or set to the default checked state' do
      expect(visit1.quantities_customized?).to eq(false)
      visit1.update_attributes(research_billing_qty: 1)
      expect(visit1.quantities_customized?).to eq(false)
    end

    it 'should return true if any of the quantities are set by the user' do
      visit1.update_attributes(research_billing_qty: 2, insurance_billing_qty: 1, effort_billing_qty: 1)
      expect(visit1.quantities_customized?).to eq(true)
    end
  end

  describe 'belongs to service request' do

    it 'should return true if the visit belongs to a given service request' do
      expect(visit1.belongs_to_service_request?(service_request)).to eq(true)
    end
  end
end