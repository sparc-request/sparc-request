require 'spec_helper'

describe "visit schedule", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:core_17)  { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_13)  { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_16)  { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_15)  { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:service3) { FactoryGirl.create(:service, organization_id: core_13.id, name: "Super Duper Service") }
  let!(:service4) { FactoryGirl.create(:service, organization_id: core_15.id, name: "Organ Harvest Service") }

  context "updating a subject" do

    before :each do
      core_17.tag_list.add("nutrition")
      core_13.tag_list.add("nursing")
      core_16.tag_list.add("laboratory")
      core_15.tag_list.add("imaging")
      core_17.save
      core_13.save
      core_16.save
      core_15.save
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

    describe "changing the visit" do

      it "should change the visit" do
        select("#2: Visit 2", from: "visit")
        wait_for_javascript_to_finish
        find("#visit").should have_value("#2: Visit 2")
      end
    end

    describe "returning to clinical fulfillment" do

      it "should return the user to clinical fulfillment" do
        click_on "Return to Clinical Work Fulfillment"
        page.should have_content("Add a subject")
      end
    end
  end
end