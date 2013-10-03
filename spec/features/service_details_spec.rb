require 'spec_helper'

## need to test that smart forms work correctly
## if we only have one time fees we should still see the start and end date fields
describe "visit service details page should always show start and end date for one time fee only service requests", :js => true do
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
      old_date = project.start_date
      find('#start_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      find('#end_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).end_date)
    end
  end
end

describe "visit service details page should always show start and end date for per patient per visit only service requests", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project_and_per_patient_per_visit_only

  before :each do
    visit service_details_service_request_path service_request.id
  end
  
  describe "entering dates" do

    numerical_day = 10
    it "should save the start date" do
      old_date = project.start_date
      find('#start_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      find('#end_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).end_date)
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

  describe "entering dates" do
    numerical_day = 10
    it "should save the start date" do
      old_date = project.start_date
      find('#start_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      find('#end_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
      wait_for_javascript_to_finish
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      old_date.should_not eq(Protocol.find(project.id).end_date)
    end
  end

  describe "editing an existing arm" do
    it "should not allow you to edit an existing arms name" do
      page.should have_no_field("project_arms_attributes_0_name")
    end
    it "should save new subject count" do
      subject_count = (arm1.subject_count + 2)
      fill_in "project_arms_attributes_0_subject_count", :with => subject_count
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(arm1.id).subject_count.should eq(subject_count)
    end
    it "should save new visit count" do
      visit_count = (arm1.visit_count + 2)
      fill_in "project_arms_attributes_0_visit_count", :with => visit_count
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(arm1.id).visit_count.should eq(visit_count)
    end
  end

  describe "adding and editing an arm" do
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
      Arm.find_by_name("New Arm Test").subject_count.should eq(2)
      Arm.find_by_name("New Arm Test").visit_count.should eq(4)
    end
  end

  describe "removing an arm" do
    it "should not delete an existing arm" do
      page.should have_no_link("Remove Arm")
    end

    it "should delete a recently added arm" do
      number_of_arms = Arm.find(:all).size
      click_link("Add Arm")
      within("div.add-arm") do
        find("input[id*=name]").set("New Arm Test")
        find("input[id*=subject_count]").set(2)
        find("input[id*=visit_count]").set(4)
      end
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(:all).size.should eq(number_of_arms + 1)

      visit service_details_service_request_path service_request.id
      click_link("Remove Arm")
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(:all).size.should eq(number_of_arms)
    end

    it "should not allow you to delete the last arm" do
      number_of_arms = Arm.find(:all).size

      within("div#1") do
        click_link("Remove Arm")
      end

      within("div#2") do
        find_link("Remove Arm").should_not be_visible
      end
        
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      Arm.find(:all).size.should eq(number_of_arms - 1)
    end
  end


end
