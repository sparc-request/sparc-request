require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#mass_destroy_visit_group' do
    shared_examples_for 'no extra VisitGroups' do
      it 'should not remove any VisitGroups' do
        expect { arm.mass_destroy_visit_group }.not_to change { arm.visit_groups.size }
      end
    end

    context 'number of VisitGroups exceeds visit_count' do
      let(:arm) do
        a = create(:arm, visit_count: 2, line_item_count: 1)
        a.update_attributes(visit_count: 1)
        a
      end

      it 'should remove extra VisitGroups from the end' do
        first_vg_id = arm.visit_groups.first.id
        expect { arm.mass_destroy_visit_group }.to change { arm.visit_groups.size }.from(2).to(1)
        expect(arm.reload.visit_groups.first.id).to eq first_vg_id
      end
    end

    context 'number of VisitGroups same as visit_count' do
      let(:arm) { create(:arm, visit_count: 1, line_item_count: 1) }

      it_behaves_like 'no extra VisitGroups'
    end

    context 'visit_count exceeds number of VisitGroups' do
      let(:arm) do
        a = create(:arm, visit_count: 1, line_item_count: 1)
        a.update_attributes(visit_count: 2)
        a
      end

      it_behaves_like 'no extra VisitGroups'
    end
  end
end
