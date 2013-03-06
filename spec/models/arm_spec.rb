require 'spec_helper'

describe Arm do
  it 'should be possible to create an arm' do
    arm = Arm.create!()
    arm.line_items.should eq [ ]
  end
end
