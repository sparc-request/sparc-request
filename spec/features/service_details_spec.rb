# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

## need to test that smart forms work correctly
## if we only have one time fees we should still see the start and end date fields
RSpec.describe "visit service details page should always show start and end date for one time fee only service requests", js: true do
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
      enter_start_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      enter_end_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).end_date)
    end
  end
end

RSpec.describe "visit service details page should always show start and end date for per patient per visit only service requests", js: true do
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
      enter_start_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      enter_end_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).end_date)
    end
  end
end

##TODO: This test suite will need updated. At the moment, roughly half of the validation for this page is non-existent/was never written,
## so the tests (obviously) don't test for it.
RSpec.describe "submitting a in form", js: true do
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
      enter_start_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).start_date)
    end
    it "should save the end date" do
      old_date = project.end_date
      enter_end_date(numerical_day)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(old_date).not_to eq(Protocol.find(project.id).end_date)
    end
  end

  describe "editing an existing arm" do

    before :each do
      @service_request2 = ServiceRequest.new(attributes_for(:service_request, protocol_id: project.id, status: 'draft'))
      @service_request2.save(validate: false)
      sub_service_request = create(:sub_service_request, ssr_id: "0001", service_request_id: @service_request2.id, organization_id: program.id,status: "draft")
      line_item = create(:line_item, service_request_id: @service_request2.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0)
      visit service_details_service_request_path @service_request2.id
    end

    it "should save new subject count" do
      subject_count = (arm1.subject_count + 2)
      find("#project_arms_attributes_0_subject_count").set(subject_count)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(Arm.find(arm1.id).subject_count).to eq(subject_count)
    end

    it "should save new visit count" do
      visit_count = (arm1.visit_count + 2)
      fill_in "project_arms_attributes_0_visit_count", with: visit_count
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish
      expect(Arm.find(arm1.id).visit_count).to eq(visit_count)
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
        expect(Arm.find_by_name("New Arm Test")).not_to eq(nil)
        expect(Arm.find_by_name("New Arm Test").subject_count).to eq(2)
        expect(Arm.find_by_name("New Arm Test").visit_count).to eq(4)
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
        expect(Arm.find(:all).size).to eq(number_of_arms + 1)

        visit service_details_service_request_path @service_request2.id
        wait_for_javascript_to_finish
        first(".remove_arm").click
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        expect(Arm.find(:all).size).to eq(number_of_arms)
      end

      it "should not allow you to delete the last arm" do
        number_of_arms = Arm.find(:all).size

        find_by_id("1").click_link("Remove Arm")
        wait_for_javascript_to_finish
        expect(find_by_id("2")).not_to have_content("Remove Arm")

        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        expect(Arm.find(:all).size).to eq(number_of_arms - 1)
      end

      it "should not allow you to delete an arm that has patient data" do
        number_of_arms = Arm.find(:all).size
        subject        = create(:subject, arm_id: arm1.id)
        appointment    = create(:appointment, calendar_id: subject.calendar.id)
        visit service_details_service_request_path service_request.id

        accept_alert("This arm has subject data and cannot be removed") do
          find_by_id("1").click_link("Remove Arm")
          wait_for_javascript_to_finish
        end

        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        wait_for_javascript_to_finish
        expect(Arm.find(:all).size).to eq(number_of_arms)
      end
    end
  end
end

def enter_start_date numerical_day
  page.execute_script("$('#start_date').focus()")
  sleep 2
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
  page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
  sleep 2
end
def enter_end_date numerical_day
  page.execute_script("$('#end_date').focus()")
  sleep 2
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month
  page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
  sleep 2
end
