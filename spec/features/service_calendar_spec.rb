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

describe "service calendar", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    visit service_calendar_service_request_path service_request.id
    arm1.reload
    arm2.reload
  end

  after :each do
    wait_for_javascript_to_finish
  end
  
  describe "one time fee form" do
    before :each do
      arm1.visit_groups.each {|vg| vg.update_attribute(:day, 1)}
      arm2.visit_groups.each {|vg| vg.update_attribute(:day, 1)}
    end

    describe "submitting form" do

      it "should save the new quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", :with => 10
        find(:xpath, "//a/img[@alt='Goback']/..").click
        wait_for_javascript_to_finish
        LineItem.find(line_item.id).quantity.should eq(10)
      end

      it "should save the new units per quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", :with => line_item.service.current_pricing_map.units_per_qty_max
        find(:xpath, "//a/img[@alt='Goback']/..").click
        wait_for_javascript_to_finish
        LineItem.find(line_item.id).units_per_quantity.should eq(line_item.service.current_pricing_map.units_per_qty_max)
      end
    end

    describe "validation" do

      describe "unit minimum too low" do

        it "Should throw errors" do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", :with => 1
          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", :with => 0
          find("#service_request_line_items_attributes_#{line_item.id}_units_per_quantity").click
          wait_for_javascript_to_finish
          find("div#one_time_fee_errors").should have_content("is less than the unit minimum")
        end
      end
      describe "units per quantity too high" do

        it "should throw js error" do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", :with => (line_item.service.current_pricing_map.units_per_qty_max + 1)
          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", :with => 1
          wait_for_javascript_to_finish
          find("div#unit_max_error").should have_content("more than the maximum allowed")
        end
      end
    end
  end

  describe "display rates" do
    it "should not show the full rate if your cost > full rate" do
      first(".service_rate_#{arm1.line_items_visits.first.id}").should have_exact_text("")
    end
  end

  describe "per patient per visit" do

    describe "template tab" do

      describe 'selecting visits' do

        it 'should jump to the selected visits' do
          select("Visits 6 - 10 of 10", from: "jump_to_visit_#{arm1.id}")
          wait_for_javascript_to_finish
          page.should have_content("Visit 6")
        end
      end

      describe "selecting check row button" do

        it "should check all visits" do
          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish
          first(".total_#{arm1.line_items_visits.first.id}").should have_exact_text('$300.00') # Probably a better way to do this. But this should be the 10 visits added together.
        end

        it "should uncheck all visits" do
          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish
          first(".total_#{arm1.line_items_visits.first.id}").should have_exact_text('$300.00') # this is here to wait for javascript to finish

          remove_from_dom(".total_#{arm1.line_items_visits.first.id}")
          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish
          first(".total_#{arm1.line_items_visits.first.id}").should have_exact_text('$0.00') # Probably a better way to do this.
        end
      end

      describe "selecting check column button" do

        it "should check all visits in the given column" do
          wait_for_javascript_to_finish
          first("#check_all_column_3").click
          wait_for_javascript_to_finish

          find("#visits_#{arm1.line_items_visits.first.visits[2].id}").checked?.should eq(true)
        end

        it "should uncheck all visits in the given column" do
          wait_for_javascript_to_finish
          first("#check_all_column_3").click        
          wait_for_javascript_to_finish
          

          find("#visits_#{arm1.line_items_visits.first.visits[2].id}").checked?.should eq(true)
          wait_for_javascript_to_finish
          first("#check_all_column_3").click
          wait_for_javascript_to_finish

          find("#visits_#{arm1.line_items_visits.first.visits[2].id}").checked?.should eq(false)
        end
      end

      describe "changing subject count" do

        before :each do
          visit_id = arm1.line_items_visits.first.visits[1].id
          page.check("visits_#{visit_id}")
          select "2", :from => "line_items_visit_#{arm1.line_items_visits.first.id}_count"
        end

        it "should not change maximum totals" do
          find(".pp_max_total_direct_cost.arm_#{arm1.id}").should have_exact_text("$30.00")
        end
      end
    end

    describe "billing strategy tab" do

      before :each do
        click_link "billing_strategy_tab"
        @visit_id = arm1.line_items_visits.first.visits[1].id
      end

      describe "selecting check all row button" do

        it "should overwrite the quantity in research billing box" do
          fill_in "visits_#{@visit_id}_research_billing_qty", :with => 10
          wait_for_javascript_to_finish
          click_link "check_row_#{arm1.line_items_visits.first.id}_billing_strategy"
          wait_for_javascript_to_finish
          find("#visits_#{@visit_id}_research_billing_qty").should have_value("1")
        end
      end

      describe "increasing the 'R' billing quantity" do

        # before :each do
        #   @visit_id = arm1.line_items_visits.first.visits[1].id
        # end

        it "should increase the total cost" do
         
          find("#visits_#{@visit_id}_research_billing_qty").set("")
          find("#visits_#{@visit_id}_research_billing_qty").click()
          fill_in( "visits_#{@visit_id}_research_billing_qty", :with => 10)
          find("#visits_#{@visit_id}_insurance_billing_qty").click()
          wait_for_javascript_to_finish

          all(".pp_max_total_direct_cost.arm_#{arm1.id}").each do |x|
            if x.visible?
              x.should have_exact_text("$300.00")
            end
          end
        end

        it "should update each visits maximum costs" do

          find("#visits_#{@visit_id}_research_billing_qty").set("")
          find("#visits_#{@visit_id}_research_billing_qty").click()
          fill_in "visits_#{@visit_id}_research_billing_qty", :with => 10
          find("#visits_#{@visit_id}_insurance_billing_qty").click()

          wait_for_javascript_to_finish

          sleep 3 # TODO: ugh: I got rid of all the sleeps, but I can't get rid of this one
     
          all(".visit_column_2.max_direct_per_patient.arm_#{arm1.id}").each do |x|
            if x.visible?
              x.should have_exact_text("$300.00")
            end
          end

          if USE_INDIRECT_COST
            all(".visit_column_2.max_indirect_per_patient.arm_#{arm1.id}").each do |x|
              if x.visible?
                x.should have_exact_text "$150.00"
              end
            end
          end
        end
      end

      describe "increasing the '%' or 'T' billing quantity" do

        before :each do
          @visit_id = arm1.line_items_visits.first.visits[1].id
        end

        it "should not increase the total cost" do

          remove_from_dom('.pp_max_total_direct_cost')

          # Putting values in these fields should not increase the total
          # cost
          fill_in "visits_#{@visit_id}_insurance_billing_qty", :with => 10
          find("#visits_#{@visit_id}_effort_billing_qty").click()

          fill_in "visits_#{@visit_id}_effort_billing_qty", :with => 10
          find("#visits_#{@visit_id}_research_billing_qty").click()

          fill_in "visits_#{@visit_id}_research_billing_qty", :with => 1
          find("#visits_#{@visit_id}_insurance_billing_qty").click()

          all(".pp_max_total_direct_cost.arm_#{arm1.id}").each do |x|
            if x.visible?
              x.should have_exact_text "$30.00"
            end
          end
        end
      end
    end

    describe "quantity tab" do

      before :each do
        @visit_id = arm1.line_items_visits.first.visits[1].id
      end

      it "should add all billing quantities together" do
        click_link "billing_strategy_tab"
        wait_for_javascript_to_finish

        visit_id = @visit_id

        fill_in "visits_#{visit_id}_research_billing_qty", :with => 10
        find("#visits_#{visit_id}_insurance_billing_qty").click()
        wait_for_javascript_to_finish

        fill_in "visits_#{visit_id}_insurance_billing_qty", :with => 10
        find("#visits_#{visit_id}_effort_billing_qty").click()
        wait_for_javascript_to_finish

        fill_in "visits_#{visit_id}_effort_billing_qty", :with => 10
        find("#visits_#{visit_id}_research_billing_qty").click()
        wait_for_javascript_to_finish

        click_link "quantity_tab"
        wait_for_javascript_to_finish

        all(".visit.visit_column_2.arm_#{arm1.id}").each do |x|
          if x.visible?
            x.should have_exact_text('30')
          end
        end
      end
    end

    describe "calendar tab" do

      before :each do
        @visit_id = arm1.line_items_visits.first.visits[1].id
      end

      it "should be blank if the visit is not checked" do
        click_link "calendar_tab"
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.should have_exact_text('')
          end
        end
      end

      it "should show total price for that visit" do
        click_link "billing_strategy_tab"
        fill_in "visits_#{@visit_id}_research_billing_qty", :with => 5
        click_link "calendar_tab"
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.should have_exact_text('150.00')
          end
        end
      end
    end

    describe "hovering over visit name text box" do

      it "should open up a qtip message" do
        wait_for_javascript_to_finish
        first('.visit_name').click
        wait_for_javascript_to_finish
        page.should have_content("Click to rename your visits.")
      end
    end
  end
end

