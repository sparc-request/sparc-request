require 'spec_helper'

describe "visit schedule", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:core_17){ FactoryGirl.create(:core, parent_id: program.id, id: 17)}
  let!(:core_13){ FactoryGirl.create(:core, parent_id: program.id, id: 13)}
  let!(:core_16){ FactoryGirl.create(:core, parent_id: program.id, id: 16)}
  let!(:core_15){ FactoryGirl.create(:core, parent_id: program.id, id: 15)}

  context "updating a subject" do

    before :each do
      service2.update_attributes(:organization_id => core_17.id)
      add_visits
      build_clinical_data(true)
      sub_service_request.update_attributes(:in_work_fulfillment => true)
      visit study_tracker_sub_service_request_path sub_service_request.id
      arm1.reload
      arm2.reload
      click_on("Subject Tracker")
      find("#schedule_1").click
    end

    describe "changing the status" do

      it "should save the new status" do
        select("Active", from: "subject[status]")
        click_button "Save Appointments"
        find("#subject_status").should have_value("Active")
      end
    end
    
    describe "checking completed" do

      it "should place the procedure in completed status" do
        check("subject_calendar_attributes_appointments_attributes_0_procedures_attributes_0_completed")
        click_button "Save Appointments"
        find("#subject_calendar_attributes_appointments_attributes_0_procedures_attributes_0_completed").should be_checked
      end
    end
  end
end