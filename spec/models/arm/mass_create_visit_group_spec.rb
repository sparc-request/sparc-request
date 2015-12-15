require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#mass_create_visit_group' do
    let(:arm) { create(:arm, visit_count: 3) }
    let(:sr)  { create(:service_request_without_validations) }
    let(:li)  { create(:line_item_with_service, service_request: sr) }
    let(:liv) { create(:line_items_visit, arm: arm, line_item: li) }

    before(:each) do
      2.times do
        vg = create(:visit_group_without_validations, arm: arm)
        create(:visit, line_items_visit: liv, visit_group: vg)
      end
      arm.reload
    end

    it 'should add VisitGroups to Arm until the number of VisitGroups equals visit_count' do
      expect(VisitGroup).to receive(:import).with([:name, :arm_id, :position], [["Visit 3", arm.id, 3]], { validate: true })
      arm.mass_create_visit_group
    end

    it 'should add Visits to newly created VisitGroups' do
      expected_new_vg_id = VisitGroup.last.id + 1
      expect(Visit).to receive(:import).with([:visit_group_id, :line_items_visit_id], [[expected_new_vg_id, liv.id]], { validate: true })
      arm.mass_create_visit_group
    end
  end
end
