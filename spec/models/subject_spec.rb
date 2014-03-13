require 'spec_helper'

describe 'Subject' do
  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_study

    let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, ssr_id: "0002", service_request_id: service_request.id, organization_id: program.id, status: "submitted") }
    let!(:service3)             { FactoryGirl.create(:service, organization_id: program.id, name: 'Per Patient') }
    let!(:line_item3)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request2.id, quantity: 0) }

    before :each do
      add_visits
      build_clinical_data
    end

    describe "populate" do
    	it "should populate calendar with appointments, and procedures" do
    		arm1.subjects.size.should eq(2)
        arm1.subjects.first.calendar.appointments.size.should eq(arm1.visit_groups.size)

        line_item3.line_items_visits.first.procedures.size.should eq(20)

        li_id = line_item2.id
        line_item2.destroy
        Procedure.find_by_line_item_id(li_id).should eq(nil)
    	end
    end

    describe "populate new subjects" do

      it "should populate the calendar of new subjects but not old ones" do
        new_subject = arm1.subjects.create()
        arm1.populate_new_subjects

        arm1.subjects.count.should eq(3)
        new_subject.calendar.appointments.size.should eq(arm1.visit_groups.size)
        arm1.subjects.first.calendar.appointments.size.should eq(arm1.visit_groups.size)
        arm1.subjects.first.calendar.appointments.map {|x| x.procedures.count}.inject(:+).should eq(
          arm1.subjects.last.calendar.appointments.map {|x| x.procedures.count}.inject(:+))
      end

    end
  end
end