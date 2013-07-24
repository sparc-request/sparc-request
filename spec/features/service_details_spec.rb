require 'spec_helper'

## need to test that smart forms work correctly
## if we only have one time fees we should still see the start and end date fields
describe "visit service details page with one time fees only", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project_and_one_time_fees_only

  before :each do
    visit service_details_service_request_path service_request.id
  end
  
  describe "entering dates" do
    numerical_day = 10
    it "should save the start date" do
      old_date = service_request.start_date
      find('#start_date').click
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(ServiceRequest.find(service_request.id).start_date)
    end
    it "should save the end date" do
      old_date = service_request.end_date
      find('#end_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(ServiceRequest.find(service_request.id).end_date)
    end
  end
end

##TODO: This test suite will need updated. At the moment, roughly half of the validation for this page is non-existent/was never written,
## so the tests (obviously) don't test for it.
describe "submitting a in form", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    visit service_details_service_request_path service_request.id
  end

  describe "one time fee form" do
    describe "submitting form" do
      it "should save the new quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", :with => 10
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        LineItem.find(line_item.id).quantity.should eq(10)
      end
      it "should save the new units per quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", :with => line_item.service.current_pricing_map.units_per_qty_max
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        LineItem.find(line_item.id).units_per_quantity.should eq(line_item.service.current_pricing_map.units_per_qty_max)
      end
    end
    describe "validation" do
      describe "unit minimum too low" do
        it "Should throw errors" do
          sleep 5
          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", :with => (line_item.service.current_pricing_map.unit_minimum - 1)
          find(:xpath, "//a/img[@alt='Savecontinue']/..").click
          wait_for_javascript_to_finish
          find("div#one_time_fee_errors").should have_content("is less than the unit minimum")
        end
      end
      describe "units per quantity too high" do
        it "should throw js error" do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", :with => (line_item.service.current_pricing_map.units_per_qty_max + 1)
          find("table.one-time-fees").click
          wait_for_javascript_to_finish
          find("div#unit_max_error").should have_content("more than the maximum allowed")
        end
      end
    end
  end

  describe "entering dates" do
    numerical_day = 10
    it "should save the start date" do
      old_date = service_request.start_date
      find('#start_date').click
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(ServiceRequest.find(service_request.id).start_date)
    end
    it "should save the end date" do
      old_date = service_request.end_date
      find('#end_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(ServiceRequest.find(service_request.id).end_date)
    end
  end

  describe "editing an arm" do
    it "should save the new name" do
      fill_in "service_request_arms_attributes_0_name", :with => "Test Rename"
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find_by_name("Test Rename").should_not eq(nil)
    end
    it "should save new subject count" do
      subject_count = (arm1.subject_count + 2)
      fill_in "service_request_arms_attributes_0_subject_count", :with => subject_count
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(arm1.id).subject_count.should eq(subject_count)
    end
    it "should save new visit count" do
      visit_count = (arm1.visit_count + 2)
      fill_in "service_request_arms_attributes_0_visit_count", :with => visit_count
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(arm1.id).visit_count.should eq(visit_count)
    end
  end

  describe "adding an arm" do
    it "should save the new arm" do
      click_link("Add Arm")
      within("div.add-arm") do
        find("input[id*=name]").set("New Arm Test")
        find("input[id*=subject_count]").set(2)
        find("input[id*=visit_count]").set(4)
      end
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find_by_name("New Arm Test").should_not eq(nil)
    end
  end

  describe "removing an arm" do
    it "should delete the arm" do
      number_of_arms = Arm.find(:all).size
      within("div#1") do
        click_link("Remove Arm")
      end
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(:all).size.should eq(number_of_arms - 1)
    end
  end
end
