require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#create_line_items_visit' do
    let!(:service_request) { create(:service_request_without_validations) }
    let!(:line_item)       { create(:line_item_with_service, service_request: service_request) }

    context 'visit_count is nil' do
      let!(:arm) { create(:arm, visit_count: nil) }

      it 'should set visit_count to 1' do
        arm.create_line_items_visit line_item
        expect(arm.visit_count).to eq 1
      end
    end

    context 'visit_count is not nil' do
      let!(:arm) { create(:arm, visit_count: 3) }

      context 'Arm has fewer VisitGroups than visit_count' do
        before(:each) do
          arm.create_visit_group 0
          arm.create_visit_group 0
        end

        it 'should create a LineItemsVisit for LineItem with new Visits' do
          vg_count = arm.visit_groups.count
          arm.update_attributes(subject_count: 1)
          expect { arm.create_line_items_visit line_item }.to change { arm.reload.line_items_visits.count }.from(0).to(1)
          liv = arm.reload.line_items_visits.first
          expect(liv.line_item).to              eq line_item
          expect(liv.subject_count).to          eq arm.subject_count

          expect(liv.visits.count).to           eq vg_count
          expect(liv.visits.map(&:position)).to eq (0..vg_count-1).to_a
        end
      end
    end
  end
end
