require 'spec_helper'

describe 'Subject' do
  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_study

    before :each do
      add_visits
      build_clinical_data
    end

    describe "populate" do
    	it "should populate calendar with appointments, and procedures" do
    		arm1.subjects.size.should eq(1)
        arm1.subjects.first.calendar.appointments.size.should eq(arm1.visit_groups.size)

        line_item2.procedures.size.should eq(15)

        li_id = line_item2.id
        line_item2.destroy
        Procedure.find_by_line_item_id(li_id).should eq(nil)
    	end
    end
  end
end