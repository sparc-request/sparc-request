require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#default_visit_days' do
    let!(:arm)    { create(:arm, visit_count: 2, line_item_count: 1) }
    before(:each) do
      VisitGroup.all.each { |vg| vg.update_attributes(day: nil) }
    end

    it 'should set the day for each VisitGroup to its position' do
      expect { arm.default_visit_days }.to change { arm.visit_groups.pluck :day }.from([nil, nil]).to([5, 10])
    end
  end
end
