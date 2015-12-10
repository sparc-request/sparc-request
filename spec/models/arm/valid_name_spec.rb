require 'rails_helper'

RSpec.describe Arm, type: :model do

  describe '#valid_name?' do

    it 'should return false if name equals nil' do
      expect(Arm.new(name: nil).valid_name?).to be false
    end

    it 'should return false if name has length 0' do
      expect(Arm.new(name: '').valid_name?).to be false
    end

    it 'should return true if name has positive length' do
      expect(Arm.new(name: 'Arm1').valid_name?).to be true
    end
  end
end
