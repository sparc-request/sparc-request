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
      sub_service_request.update_attributes(status: 'submitted')
      find("#schedule_1").click
    end

    describe "changing the status" do

      it "should save the new status" do
        select("Active", from: "subject[status]")
        click_button "Save Appointments"
        page.driver.browser.switch_to.alert.dismiss
        find("#subject_status").should have_value("Active")
      end
    end

    describe "changing the visit" do

      it "should change the visit" do
        select("#2: Visit 2", from: "visit")
        wait_for_javascript_to_finish
        find("#visit").should have_value("#2: Visit 2")
        click_button "Save Appointments"
        page.driver.browser.switch_to.alert.dismiss
      end
    end

    describe "returning to clinical fulfillment" do

      it "should return the user to clinical fulfillment" do
        click_on "Return to Clinical Work Fulfillment"
        wait_for_javascript_to_finish
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
        click_button "Save Appointments"
        page.driver.browser.switch_to.alert.dismiss
      end
    end

    describe "changing the r quantity" do

      it "should save the new quantity" do
        click_on "Nutrition"
        find(".procedure_r_qty", :visible => true).set("10")
        click_button "Save Appointments"
        page.driver.browser.switch_to.alert.dismiss
        find(".procedure_r_qty", :visible => true).should have_value("10")
      end
    end

    describe "changing the t quantity" do

      it "should save the new quantity" do
        click_on "Nutrition"
        retry_until { find(".procedure_t_qty", :visible => true).set("10") }
        click_button "Save Appointments"
        page.driver.browser.switch_to.alert.dismiss
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
          page.driver.browser.switch_to.alert.dismiss
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
          click_button "Save Appointments"
          page.driver.browser.switch_to.alert.dismiss
        end
      end
    end

    describe "validating the date" do

      it "should not allow you to save if the completed date is not filled in" do
        click_on "Nutrition"
        wait_for_javascript_to_finish
        click_button "Save Appointments"
        a = page.driver.browser.switch_to.alert
        a.text.should eq "Please select a date for this visit before saving."
        a.accept
      end

      it "should save if the date is entered" do
        click_on "Nutrition"
        wait_for_javascript_to_finish
        find('.hasDatepicker', :visible => true).set("06/13/2014")
        click_button "Save Appointments"
        page.should_not have_content("Please select a date for this visit before saving.")
      end

    end
  end
end