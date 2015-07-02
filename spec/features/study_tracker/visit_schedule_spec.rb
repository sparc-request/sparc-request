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

RSpec.describe "visit schedule", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:service3)     { create(:service, organization_id: program.id, name: 'Super Awesome Terrific') }
  let!(:pricing_map3) { create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service3.id, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }
  let!(:line_item3)   { create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request.id, quantity: 0) }

  context "updating a subject" do

    before :each do
      service2.update_attributes(organization_id: core_17.id)
      service3.update_attributes(organization_id: core_13.id)
      add_visits
      build_clinical_data(true)
      sub_service_request.update_attributes(in_work_fulfillment: true)
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
        accept_alert do
          click_button "Save Appointments"
        end
        expect(find("#subject_status")).to have_value("Active")
      end
    end

    describe "changing the visit" do

      it "should change the visit" do
        select("#2: Visit 2", from: "visit")
        wait_for_javascript_to_finish
        expect(find("#visit")).to have_value("#2: Visit 2")
        accept_alert do
          click_button "Save Appointments"
        end
      end
    end

    describe "returning to clinical fulfillment" do

      it "should return the user to clinical fulfillment" do
        find("#bottom_return_link").click
        wait_for_javascript_to_finish
        expect(page).to have_content("Add a subject")
      end
    end

    describe "changing to a different core" do

      it "should filter by that core's procedures when its tab is clicked" do
        click_on "Nutrition"
        expect(page).to have_content("Per Patient")
        click_on "Nursing"
        expect(page).not_to have_content("Per Patient")
        expect(page).to have_content("Super Awesome Terrific")
      end
    end

    describe "adding a message" do

      it "should save the message and display it on the page" do
        retry_until { first("#notes").set("Messages all up in this place.") }
        first('.add_comment_link').click
        expect(page).to have_content("Messages all up in this place.")
        accept_alert do
          click_button "Save Appointments"
        end
      end
    end

    describe "changing the r quantity" do

      it "should save the new quantity" do
        click_on "Nutrition"
        find(".procedure_r_qty", visible: true).set("10")
        accept_alert do
          click_button "Save Appointments"
        end
        expect(find(".procedure_r_qty", visible: true)).to have_value("10")
      end
    end

    describe "changing the t quantity" do

      it "should save the new quantity" do
        click_on "Nutrition"
        retry_until { find(".procedure_t_qty", visible: true).set("10") }
        accept_alert do
          click_button "Save Appointments"
        end
        expect(find(".procedure_t_qty", visible: true)).to have_value("10")
      end
    end

    context "changing the totals" do

      describe "checking completed" do

        it "should place the procedure in completed status" do
          click_on "Nutrition"
          find(:css, ".procedure_box", visible: true).set(false)
          expect(find(".procedure_box", visible: true)).not_to be_checked
          find(:css, ".procedure_box", visible: true).set(true)
          accept_alert do
            click_button "Save Appointments"
          end
          expect(find(".procedure_box", visible: true)).to be_checked
        end

        it "should display procedure's total as zero if left unchecked" do
          click_on "Nutrition"
          find(:css, ".procedure_box", visible: true).set(false)
          expect(find(".procedure_total_cell", visible: true)).to have_text("$0.00")
        end

        it "should diplay the correct total if it is checked" do
          click_on "Nutrition"
          wait_for_javascript_to_finish
          find(:css, ".procedure_box", visible: true).set(false)
          find(:css, ".procedure_box", visible: true).set(true)
          expect(find(".procedure_total_cell", visible: true)).to have_text("$150.00")
          accept_alert do
            click_button "Save Appointments"
          end
        end
      end
    end

    describe "validating the date" do

      it "should not allow you to save if the completed date is not filled in" do
        click_on "Nutrition"
        wait_for_javascript_to_finish
        accept_alert("Please select a date for this visit before saving.") do
          click_button "Save Appointments"
        end
      end

      it "should save if the date is entered" do
        click_on "Nutrition"
        wait_for_javascript_to_finish
        find('.hasDatepicker', visible: true).set("06/13/2014")
        click_button "Save Appointments"
        expect(page).not_to have_content("Please select a date for this visit before saving.")
      end
    end
  end
end
