require 'rails_helper'

RSpec.describe Arm, type: :model do

  describe '#valid_visit_count?' do

    it 'should return false if visit_count equals nil' do
      expect(Arm.new(visit_count: nil).valid_visit_count?).to be false
    end

    it 'should return false if visit_count equals 0' do
      expect(Arm.new(visit_count: 0).valid_visit_count?).to be false
    end

    it 'should return false if visit_count is negative' do
      expect(Arm.new(visit_count: -1).valid_visit_count?).to be false
    end

    it 'should return true if visit_count is positive' do
      expect(Arm.new(visit_count: 1).valid_visit_count?).to be true
    end
  end
end
