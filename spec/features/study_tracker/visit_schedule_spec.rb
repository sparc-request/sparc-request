require 'spec_helper'

describe "visit schedule", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:service3)     { FactoryGirl.create(:service, organization_id: program.id, name: 'Super Awesome Terrific') }
  let!(:pricing_map3) { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service3.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }
  let!(:line_item3)   { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request.id, quantity: 0) }

  context "updating a subject" do

    before :each do
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
        click_on "Nutrition"
        find(".procedure_r_qty", :visible => true).set("10")
        click_button "Save Appointments"
        find(".procedure_r_qty", :visible => true).should have_value("10")
      end
    end

    describe "changing the t quantity" do

      it "should save the new quantity" do
        click_on "Nutrition"
        retry_until { find(".procedure_t_qty", :visible => true).set("10") }
        click_button "Save Appointments"
        find(".procedure_t_qty", :visible => true).should have_value("10")
      end
    end

    context "changing the totals" do

      describe "checking completed" do

        it "should place the procedure in completed status" do
          click_on "Nutrition"
          find(:css, ".procedure_box", :visible => true).set(false)
          find(".procedure_box", :visible => true).should_not be_checked
          find(:css, ".procedure_box", :visible => true).set(true)
          click_button "Save Appointments"
          find(".procedure_box", :visible => true).should be_checked
        end

        it "should display procedure's total as zero if left unchecked" do
          click_on "Nutrition"
          find(:css, ".procedure_box", :visible => true).set(false)
          find(".procedure_total_cell", :visible => true).should have_text("$0.00")
        end

        it "should diplay the correct total if it is checked" do
          click_on "Nutrition"
          wait_for_javascript_to_finish
          find(:css, ".procedure_box", :visible => true).set(false)
          find(:css, ".procedure_box", :visible => true).set(true)
          find(".procedure_total_cell", :visible => true).should have_text("$150.00")
        end
      end
    end
  end
end