require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#mass_create_visit_group' do
    let(:arm) { create(:arm, visit_count: 2, line_item_count: 2) }

    before(:each) do
      arm.update(visit_count: 5)
      arm.reload
    end

    it 'should add VisitGroups to Arm until the number of VisitGroups equals visit_count' do
      expect { arm.mass_create_visit_group }.to change { arm.visit_groups.count }.from(2).to(5)
    end

    it 'should add new VisitGroups with incrementing positions beginning at last_position + 1' do
      last_position = arm.visit_groups.last.position
      old_vg_ids    = arm.visit_groups.pluck :id
      arm.mass_create_visit_group
      new_positions = arm.visit_groups.where.not(id: old_vg_ids).pluck(:position)
      expect(new_positions).to eq ((last_position+1)..(last_position+3)).to_a
    end

    it 'should add Visits to newly created VisitGroups' do
      old_vg_ids    = arm.visit_groups.pluck :id
      arm.mass_create_visit_group
      visit_counts_for_new_vgs = arm.visit_groups.where.not(id: old_vg_ids).map { |vg| vg.visits.count }
      expect(visit_counts_for_new_vgs).to eq [2, 2, 2]
    end
  end
end
