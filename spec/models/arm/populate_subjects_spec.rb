require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#populate_subjects' do
    context 'number of associated Subjects exceeds subject_count' do
      let!(:arm) { create(:arm, subject_count: 1) }
      before(:each) do
        2.times { arm.subjects.create }
      end

      it 'should not create any Subjects' do
        expect { arm.populate_subjects }.not_to change { arm.subjects.count }
      end
    end

    context 'number of associated Subjects equals subject_count' do
      let!(:arm) { create(:arm, subject_count: 1) }
      before(:each) do
        arm.subjects.create
      end

      it 'should not create any Subjects' do
        expect { arm.populate_subjects }.not_to change { arm.subjects.count }
      end
    end

    context 'subject_count exceeds number of associated Subjects' do
      let!(:arm) { create(:arm, subject_count: 3) }
      before(:each) do
        arm.subjects.create
      end

      it 'should create enough Subjects so that there are subject_count total' do
        expect { arm.populate_subjects }.to change { arm.subjects.count }.from(1).to(3)
      end
    end
  end
end
