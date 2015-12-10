require 'rails_helper'

RSpec.describe Arm, type: :model do

  describe '#valid_subject_count?' do

    it 'should return false if subject_count equals nil' do
      expect(Arm.new(subject_count: nil).valid_subject_count?).to be false
    end

    it 'should return false if subject_count equals 0' do
      expect(Arm.new(subject_count: 0).valid_subject_count?).to be false
    end

    it 'should return false if subject_count is negative' do
      expect(Arm.new(subject_count: -1).valid_subject_count?).to be false
    end

    it 'should return true if subject_count is positive' do
      expect(Arm.new(subject_count: 1).valid_subject_count?).to be true
    end
  end
end
