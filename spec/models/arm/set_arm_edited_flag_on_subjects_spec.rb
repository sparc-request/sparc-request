require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#set_arm_edited_flag_on_subjects' do
    let!(:arm) {Arm.create(name: "arm1", visit_count: 1, subject_count: 1)}
    before(:each) { 3.times { arm.subjects.create(arm_edited: false) } }
    it 'should set arm_edited on each associated Subject' do
      arm.set_arm_edited_flag_on_subjects
      expect(arm.reload.subjects.pluck :arm_edited).to all(be true)
    end
  end
end
