require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#remove_visit' do

    it "should decrease visit_count by 1" do
      arm = create(:arm, visit_count: 1, line_item_count: 1)
      expect { arm.remove_visit(1) }.to change { arm.visit_count }.by(-1)
    end

    it "should remove VisitGroup at the specified position" do
      arm = create(:arm, visit_count: 3, line_item_count: 1)
      first_vg = arm.visit_groups.first
      third_vg = arm.visit_groups.last

      # remove middle VisitGroup
      expect { arm.remove_visit(2) }.to change { arm.reload.visit_groups.to_a }.to([first_vg, third_vg])
    end
  end
end
