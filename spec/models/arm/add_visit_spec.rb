require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#add_visit' do
    context 'visit_count nil' do
      let(:arm) { Arm.create(visit_count: nil) }

      it 'should set visit_count to 1' do
        arm.add_visit
        expect(arm.reload.visit_count).to eq 1
      end
    end

    context 'visit_count non-nil' do
      let(:arm) { Arm.create(visit_count: 1) }

      it 'should increment visit_count' do
        arm.add_visit
        expect(arm.visit_count).to eq 2
      end
    end

    context 'position not specified' do
      let!(:arm) { create(:arm, visit_count: 2, line_item_count: 2) }

      it 'should add a new VisitGroup to the end' do
        orig_vg_ids = arm.visit_groups.map &:id

        # expect change in number of VisitGroups
        expect { arm.add_visit }.to change { arm.visit_groups.count }.from(2).to(3)
        # expect first two VisitGroups to be preserved
        expect(arm.visit_groups.map &:id).to start_with orig_vg_ids
        # expect last VisitGroup to be new
        expect(orig_vg_ids).not_to include(arm.visit_groups[2].id)
      end

      it 'should add a new Visit to each LineItemsVisit to the end' do
        liv0_visit_ids = arm.line_items_visits[0].visits.map &:id
        liv1_visit_ids = arm.line_items_visits[1].visits.map &:id

        arm.add_visit
        arm.reload

        # expect change in number of Visits on each LIV
        expect(arm.line_items_visits.map { |liv| liv.visits.count }).to eq [3, 3]

        expect(arm.line_items_visits[0].visits.map &:id).to start_with liv0_visit_ids
        expect(arm.line_items_visits[1].visits.map &:id).to start_with liv1_visit_ids
        expect(liv0_visit_ids.product liv1_visit_ids).not_to include(
          [arm.line_items_visits[0].visits[2], arm.line_items_visits[1].visits[2]])
      end
    end

    context 'position specified' do
      let!(:arm) { create(:arm, visit_count: 3, line_item_count: 2) }

      it 'should add a new VisitGroup to that position' do
        position = 2
        expect { arm.add_visit position }.to change { arm.visit_groups.count }.by(1)
        expect(arm.visit_groups.at_position(position).first.id).to eq(VisitGroup.last.id)
      end

      context 'position already occupied' do
        it 'should not force the VisitGroup positions to deviate from 1, 2, 3, ...' do
          position = arm.visit_groups.last.position
          arm.add_visit position
          expect(arm.visit_groups.pluck :position).to eq [1, 2, 3, 4]
        end
      end

      it 'should add a new Visit to each LineItemsVisit to that position' do
        position = 2
        liv0_visit_ids = arm.line_items_visits[0].visits.map &:id
        liv1_visit_ids = arm.line_items_visits[1].visits.map &:id

        arm.add_visit position
        arm.reload

        # expect change in number of Visits on each LIV
        num_visits = arm.visit_groups.count
        expect(arm.line_items_visits.map { |liv| liv.visits.count }).to eq [num_visits, num_visits]

        # check order of Visits on each LIV
        expect([arm.line_items_visits[0].visits[0].id] + arm.line_items_visits[0].visits[2..3].map(&:id)).to eq liv0_visit_ids
        expect(liv0_visit_ids).not_to include(arm.line_items_visits[0].visits[1])
        expect([arm.line_items_visits[1].visits[0].id] + arm.line_items_visits[1].visits[2..3].map(&:id)).to eq liv1_visit_ids
        expect(liv1_visit_ids).not_to include(arm.line_items_visits[1].visits[1])
      end
    end

    context 'name specified' do
      it 'should set VisitGroup name' do
        arm = Arm.create
        arm.add_visit(nil, nil, 0, 0, 'Visit Group Name')
        expect(arm.visit_groups.first.name).to eq 'Visit Group Name'
      end
    end

    context 'USE_EPIC == true' do
      let(:arm) { Arm.create }

      before(:each) do
        stub_const("USE_EPIC", true)
      end

      it 'should set new VisitGroup\'s day, window_before, and window_after' do
        expect(arm).to receive(:update_visit_group_day).with(:day, 10, :portal).and_return true
        expect(arm).to receive(:update_visit_group_window_before).with(:window_before, 10, :portal).and_return true
        expect(arm).to receive(:update_visit_group_window_after).with(:window_after, 10, :portal).and_return true
        arm.add_visit 10, :day, :window_before, :window_after, "Visit Group Name", :portal
      end
    end

    context 'USE_EPIC == false' do
      let(:arm) { Arm.create }

      before(:each) do
        stub_const("USE_EPIC", false)
      end

      it 'should not set new VisitGroup\'s day, window_before, or window_after' do
        expect(arm).not_to receive(:update_visit_group_day)
        expect(arm).not_to receive(:update_visit_group_window_before)
        expect(arm).not_to receive(:update_visit_group_window_after)
        arm.add_visit 10, :day, :window_before, :window_after, "Visit Group Name", :portal
      end
    end
  end
end
