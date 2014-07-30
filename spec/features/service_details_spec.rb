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

    before :each do
      @service_request2 = ServiceRequest.new(FactoryGirl.attributes_for(:service_request, :protocol_id => project.id, :status => 'draft'))
      @service_request2.save(:validate => false)
      sub_service_request = FactoryGirl.create(:sub_service_request, ssr_id: "0001", service_request_id: @service_request2.id, organization_id: program.id,status: "draft")
      line_item = FactoryGirl.create(:line_item, service_request_id: @service_request2.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0) 
      visit service_details_service_request_path @service_request2.id
    end

    it "should save new subject count" do
      subject_count = (arm1.subject_count + 2)
      find("#project_arms_attributes_0_subject_count").set(subject_count)
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

        visit service_details_service_request_path @service_request2.id
        wait_for_javascript_to_finish
        first(".remove_arm").click
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        Arm.find(:all).size.should eq(number_of_arms)
      end

      it "should not allow you to delete the last arm" do
        number_of_arms = Arm.find(:all).size

        within("div#1") do
          sleep 3
          click_link("Remove Arm")
        end

        within("div#2") do
          sleep 3
          page.should_not have_content("Remove Arm")
        end
          
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        Arm.find(:all).size.should eq(number_of_arms - 1)
      end

      it "should not allow you to delete an arm that has patient data" do
        number_of_arms = Arm.find(:all).size
        subject = FactoryGirl.create(:subject, :arm_id => arm1.id)
        appointment = FactoryGirl.create(:appointment, :calendar_id => subject.calendar.id)
        visit service_details_service_request_path service_request.id
        within("div#1") do
          sleep 3
          click_link("Remove Arm")
        end

        a = page.driver.browser.switch_to.alert
        a.text.should eq "This arm has subject data and cannot be removed"
        a.accept

        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        Arm.find(:all).size.should eq(number_of_arms)
      end
    end
  end


end
