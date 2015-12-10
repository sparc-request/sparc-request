require 'rails_helper'

RSpec.describe Procedure, type: :model do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  before :each do
	  add_visits
	end

  describe "cost" do
    let!(:arm)							 { create(:arm, name: "Arm IV", protocol_id: protocol_for_service_request_id, visit_count: 1, subject_count: 1)}
		let!(:visit_group)       { create(:visit_group, arm_id: arm.id)}
		let!(:visit)             { create(:visit, research_billing_qty: 10, insurance_billing_qty: 10, visit_group_id: visit_group.id) }
		let!(:appointment)       { create(:appointment, visit_group_id: visit_group.id) }
		let(:procedure)          { create(:procedure, appointment_id: appointment.id, visit_id: visit.id, line_item_id: line_item.id) }

		it "should return the cost when attached to a line item" do
			expect(procedure.cost).to eq(10.0)
		end

		it "should return the cost when attached to a service" do
			expect(procedure.cost).to eq(10.0)
		end
	end
end
