require 'spec_helper'

describe VisitGrouping do
  it 'should be possible to create a visit grouping' do
    visit_grouping = VisitGrouping.create!()
    visit_grouping.arm.should eq nil
    visit_grouping.line_item.should eq nil
    visit_grouping.visits.should eq [ ]
  end
end
