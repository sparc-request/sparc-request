require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#create_line_items_visit' do
    let!(:service_request) { create(:service_request_without_validations) }
    let!(:line_item)       { create(:line_item_with_service, service_request: service_request) }

    context 'visit_count is nil' do
      it 'should set visit_count to 1' do
        arm = create(:arm_without_validations, visit_count: nil)
        arm.create_line_items_visit line_item
        expect(arm.visit_count).to eq 1
      end
    end

    context 'visit_count is positive' do
      it 'should create enough VisitGroups to match visit_count' do
        arm = create(:arm, visit_count: 2, subject_count: 1)

        arm.create_line_items_visit(line_item)

        expect(arm.visit_groups.count).to eq(2)
      end

      it 'should create a LineItemsVisit for LineItem with new Visits' do
        arm = create(:arm, visit_count: 2, subject_count: 1)

        arm.create_line_items_visit(line_item)

        expect(arm.line_items_visits.count).to eq(1)
        liv = arm.reload.line_items_visits.first
        expect(liv.line_item).to              eq line_item
        expect(liv.subject_count).to          eq arm.subject_count
        expect(liv.visits.count).to           eq arm.visit_count
        expect(liv.visits.map(&:position)).to eq (1..arm.visit_count).to_a
      end

      context 'Arm has the same number of VisitGroups as visit_count' do
        it 'should not create any VisitGroups' do
          arm = create(:arm, visit_count: 2, subject_count: 1)
          create_list(:visit_group, 2, arm: arm)

          expect { arm.create_line_items_visit line_item }.to_not change { arm.visit_groups.count }
        end
      end

      context 'Arm has more VisitGroups than visit_count' do
        it 'should not create any VisitGroups' do
          arm = create(:arm, visit_count: 2, subject_count: 1)
          create_list(:visit_group, 3, arm: arm)

          expect { arm.create_line_items_visit line_item }.to_not change { arm.visit_groups.count }
        end
      end
    end
  end
end
