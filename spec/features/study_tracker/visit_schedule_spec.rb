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
        retry_until { first("#notes").set("Messages all up in this place.") }
        first('.add_comment_link').click
        page.should have_content("Messages all up in this place.")
      end
    end

    describe "changing the r quantity" do

      it "should save the new quantity" do
        retry_until { first(".procedure_r_qty").set("10") }
        click_button "Save Appointments"
        first(".procedure_r_qty").should have_value("10")
      end
    end

    describe "changing the t quantity" do

      it "should save the new quantity" do
        retry_until { first(".procedure_t_qty").set("10") }
        click_button "Save Appointments"
        first(".procedure_t_qty").should have_value("10")
      end
    end

    context "changing the totals" do

      describe "checking completed" do

        it "should be defaulted to checked" do
          first(".procedure_box").should be_checked
        end

        it "should place the procedure in completed status" do
          first(:css, ".procedure_box").set(false)
          first(".procedure_box").should_not be_checked
          first(:css, ".procedure_box").set(true)
          click_button "Save Appointments"
          first(".procedure_box").should be_checked
        end

        it "should display procedure's total as zero if left unchecked" do
          first(:css, ".procedure_box").set(false)
          first(".procedure_total_cell").should have_text("$0.00")
        end

        it "should diplay the correct total if it is checked" do
          wait_for_javascript_to_finish
          first(:css, ".procedure_box").set(false)
          first(:css, ".procedure_box").set(true)
          first(".procedure_total_cell").should have_text("$150.00")
        end
      end
    end
  end
end