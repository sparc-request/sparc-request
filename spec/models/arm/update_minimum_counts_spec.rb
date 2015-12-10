require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#update_minimum_counts' do
    let!(:arm) { Arm.create(visit_count: 3, subject_count: 4,
                            minimum_visit_count: nil, minimum_subject_count: nil) }

    it 'should set minimum_visit_count to visit_count' do
      expect { arm.update_minimum_counts }.to change { arm.minimum_visit_count }.from(nil).to(3)
    end

    it 'should set minimum_subject_count to subject_count' do
      expect { arm.update_minimum_counts }.to change { arm.minimum_subject_count }.from(nil).to(4)
    end
  end
end
