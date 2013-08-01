require 'spec_helper'

describe "visit schedule", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:core_17)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_13)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_16)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_15)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:service3)     { FactoryGirl.create(:service, organization_id: program.id, name: 'Super Awesome Terrific') }
  let!(:pricing_map3) { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service3.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }
  let!(:line_item3)   { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request.id, quantity: 0) }

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
      service3.update_attributes(:organization_id => core_13.id)
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

    describe "changing to a different core" do

      it "should filter by that core's procedures when its tab is clicked" do
        click_on "Nutrition"
        page.should have_content("Per Patient")
        click_on "Nursing" 
        page.should_not have_content("Per Patient")
        page.should have_content("Super Awesome Terrific")
      end
    end

    describe "adding a message" do

      it "should save the message and display it on the page" do
        first("#notes").set("Messages all up in this place.")
        first('.add_comment_link').click
        page.should have_content("Messages all up in this place.")
      end
    end

    describe "changing the quantity" do

      it "should save the new quantity" do

        first(".procedure_qty").set("10")
        click_button "Save Appointments"
        first(".procedure_qty").should have_value("10")
      end
    end
  end
end