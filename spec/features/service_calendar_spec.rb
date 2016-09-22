# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe "service calendar", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits
    visit service_calendar_service_request_path service_request.id
    arm1.reload
    arm2.reload
    wait_for_javascript_to_finish
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "one time fee form" do
    before :each do
      arm1.visit_groups.each_with_index {|vg, index| vg.update_attribute(:day, index)}
      arm2.visit_groups.each_with_index {|vg, index| vg.update_attribute(:day, index)}
    end

    describe "submitting form" do

      it "should save the new quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", with: 10
        page.execute_script('$(".line_item_quantity").change()')
        wait_for_javascript_to_finish
        find('.return-to-previous').click
        wait_for_javascript_to_finish
        expect(LineItem.find(line_item.id).quantity).to eq(10)
      end

      it "should save the new units per quantity" do
        fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", with: 10
        page.execute_script('$(".units_per_quantity").change()')
        wait_for_javascript_to_finish
        find('.return-to-previous').click
        wait_for_javascript_to_finish
        expect(LineItem.find(line_item.id).units_per_quantity).to eq(10)
      end
    end

    describe 'validation' do

      describe 'unit minimum too low' do

        it 'should retain original total direct cost' do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", with: 1
          page.execute_script('$(".units_per_quantity").change()')
          wait_for_javascript_to_finish

          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", with: 0
          wait_for_javascript_to_finish
          page.execute_script('$(".line_item_quantity").change()')
          wait_for_javascript_to_finish
          
          expect(page).to have_css('.otf_total_direct_cost', text: '$50.00')
        end
      end

      describe 'units per quantity too high' do

        it 'should throw js error' do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", with: 50
          page.execute_script('$(".units_per_quantity").change()')
          wait_for_javascript_to_finish
          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", with: 1
          page.execute_script('$(".line_item_quantity").change()')
          wait_for_javascript_to_finish

          expect(page).to have_css('#unit_max_error', text: 'more than the maximum allowed')
        end

        it 'should retain original total direct cost' do
          fill_in "service_request_line_items_attributes_#{line_item.id}_units_per_quantity", with: 1
          page.execute_script('$(".units_per_quantity").change()')
          wait_for_javascript_to_finish

          fill_in "service_request_line_items_attributes_#{line_item.id}_quantity", with: 55
          page.execute_script('$(".line_item_quantity").change()')
          wait_for_javascript_to_finish

          expect(page).to have_css('.otf_total_direct_cost', text: '$50.00')
        end
      end
    end
  end

  describe "display rates" do
    it "should not show the full rate if your cost > full rate" do
      expect(first(".service_rate_#{arm1.line_items_visits.first.id}")).to have_exact_text("")
    end
  end

  describe 'per patient per visit' do

    describe 'template tab' do

      describe 'selecting visits' do

        it 'should jump to the selected visits' do
          select('Visits 6 - 10 of 10', from: "jump_to_visit_#{arm1.id}")
          wait_for_javascript_to_finish

          expect(page).to have_css("input.visit_name[value='Visit 6']")
        end
      end

      describe 'sorting visits around' do

        it 'should move visit 1 to the spevified position' do
          wait_for_javascript_to_finish
          first('.move_visits').click
          wait_for_javascript_to_finish
          select("Visit 1", from: "visit_to_move_1")
          wait_for_javascript_to_finish
          select("Insert at 2 - Visit 2", from: "move_to_position_#{arm1.id}")
          wait_for_javascript_to_finish
          find('#submit_move').click
          wait_for_javascript_to_finish
          expect(arm1.visit_groups.first.name).to eq('Visit 2')
        end

        it 'should move visit 2 between visits 6 and 7' do
          wait_for_javascript_to_finish
          first('.move_visits').click
          wait_for_javascript_to_finish
          select("Visit 2", from: "visit_to_move_1")
          wait_for_javascript_to_finish
          select("Insert at 7 - Visit 7", from: "move_to_position_1")
          find('#submit_move').click
          wait_for_javascript_to_finish
          expect(arm1.visit_groups[6].name).to eq("Visit 2")
        end

        it "should not mess up the visit ids" do
          arm1.visit_groups.each do |vg|
            wait_for_javascript_to_finish
            first('.move_visits').click
            wait_for_javascript_to_finish
            select("#{vg.name}", from: "visit_to_move_#{arm1.id}")
            # first option in move_to_position dropdown selected
            find('#submit_move').click
            wait_for_javascript_to_finish
          end

          # TODO what are we testing here?
        end
      end

      context 'check all buttons' do

        describe "selecting check all row button and accepting the validation alert" do

          it "should overwrite the quantities in the row if they are not customized" do
            click_link "check_row_#{arm1.line_items_visits.first.id}_template"
            wait_for_javascript_to_finish
            expect(first(".visits_1")).to be_checked
          end
        end

        describe "selecting check all row button and canceling the validation alert" do

          it "should not overwrite the quantities in the row if they are customized" do

            Visit.update_all(research_billing_qty: 2)
            visit service_calendar_service_request_path service_request.id
            wait_for_javascript_to_finish

            dismiss_confirm("This will reset custom values for this row, do you wish to continue?") do
              click_link "check_row_#{arm1.line_items_visits.first.id}_template"
            end
            wait_for_javascript_to_finish
            expect(first(".visits_1")).to be_checked
          end
        end

        describe "selecting check all column button and accepting the validation alert" do

          it "should overwrite the quantities in the column if they are not customized" do
            first("#check_all_column_1").click
            wait_for_javascript_to_finish
            expect(first(".visits_1")).to be_checked
          end
        end

        describe "selecting check all column button and canceling the validation alert" do

          it "should not overwrite the quantities in the column if they are customized" do
            Visit.update_all(research_billing_qty: 2)
            visit service_calendar_service_request_path service_request.id
            wait_for_javascript_to_finish

            dismiss_confirm("This will reset custom values for this column, do you wish to continue?") do
              first("#check_all_column_3").click
            end
            wait_for_javascript_to_finish
            expect(first(".visits_3")).to be_checked
          end
        end
      end

      describe "changing subject count" do

        before :each do
          visit_id = arm1.line_items_visits.first.visits[1].id
          page.check("visits_#{visit_id}")
          select "2", from: "line_items_visit_#{arm1.line_items_visits.first.id}_count"
        end

        it "should not change maximum totals" do
          expect(find(".pp_max_total_direct_cost.arm_#{arm1.id}")).to have_exact_text("$30.00")
        end
      end
    end

    describe "billing strategy tab" do

      before :each do
        click_link "billing_strategy_tab"
        @visit_id = arm1.line_items_visits.first.visits[1].id
      end

      describe "increasing the 'R' billing quantity" do
        it "should increase the total cost" do
          fill_in("visits_#{@visit_id}_research_billing_qty", with: 10)
          find('body').click
          wait_for_javascript_to_finish
          expect(first(".pp_max_total_direct_cost.arm_#{arm1.id}", visible: true)).to have_exact_text("$300.00")
        end

        it "should update each visits maximum costs" do
          fill_in "visits_#{@visit_id}_research_billing_qty", with: 10
          find('body').click
          wait_for_javascript_to_finish
          all(".visit_column_2.max_direct_per_patient.arm_#{arm1.id}").each do |x|
            if x.visible?
              expect(x).to have_exact_text("$300.00")
            end
          end

          if USE_INDIRECT_COST
            all(".visit_column_2.max_indirect_per_patient.arm_#{arm1.id}").each do |x|
              if x.visible?
                expect(x).to have_exact_text "$150.00"
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
          fill_in "visits_#{@visit_id}_insurance_billing_qty", with: 10
          find('body').click
          wait_for_javascript_to_finish

          fill_in "visits_#{@visit_id}_effort_billing_qty", with: 10
          find('body').click
          wait_for_javascript_to_finish

          fill_in "visits_#{@visit_id}_research_billing_qty", with: 1
          find('body').click
          wait_for_javascript_to_finish

          all(".pp_max_total_direct_cost.arm_#{arm1.id}").each do |x|
            if x.visible?
              expect(x).to have_exact_text "$30.00"
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

        fill_in "visits_#{visit_id}_research_billing_qty", with: 10
        find('body').click
        wait_for_javascript_to_finish

        fill_in "visits_#{visit_id}_insurance_billing_qty", with: 10
        find('body').click
        wait_for_javascript_to_finish

        fill_in "visits_#{visit_id}_effort_billing_qty", with: 10
        find('body').click
        wait_for_javascript_to_finish

        click_link "quantity_tab"
        wait_for_javascript_to_finish

        all(".visit.visit_column_2.arm_#{arm1.id}").each do |x|
          if x.visible?
            expect(x).to have_exact_text('30')
          end
        end
      end
    end

    describe "calendar tab" do

      before :each do
        @visit_id = arm1.line_items_visits.first.visits[1].id
      end

      it "should show a spinner when changed" do
        click_link "calendar_tab"
        expect(page).to have_css("#tab_load_spinner", visible: true)
      end

      it "should be blank if the visit is not checked" do
        click_link "calendar_tab"
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            expect(x).to have_exact_text('')
          end
        end
      end

      it "should show total price for that visit" do
        find("#billing_strategy_tab").click
        wait_for_javascript_to_finish
        within(".arm_#{arm1.id}.visit.visit_column_2") do
          wait_for_javascript_to_finish
          fill_in "visits_#{@visit_id}_research_billing_qty", with: "5\r"
        end

        wait_for_javascript_to_finish
        find("#calendar_tab").click
        wait_for_javascript_to_finish

        all('.pp_line_item_total total_1').each do |x|
          if x.visible?
            expect(x).to have_exact_text("150.00")
          end
        end
      end
    end

    describe "hovering over visit name text box" do

      it "should open up a qtip message" do
        wait_for_javascript_to_finish
        first('.visit_name').click
        wait_for_javascript_to_finish
        expect(page).to have_content("Click to rename your visits.")
      end
    end

    describe 'saving as draft' do

      it 'should save the request as draft if it is in first draft' do
        service_request.update_attributes(status: 'first_draft')
        sub_service_request.update_attributes(status: 'first_draft')
        click_on 'Save as Draft'
        wait_for_javascript_to_finish
        expect(page).to have_content('Filter Protocols')
      end

      it 'should save the request as draft if it is in draft and has not been previously submitted' do
        service_request.update_attributes(status: 'draft')
        sub_service_request.update_attributes(status: 'draft')
        click_on 'Save as Draft'
        wait_for_javascript_to_finish
        expect(page).to have_content('Filter Protocols')
      end

      it 'should not display the Save as Draft button if the request has been previously submitted' do
        service_request.update_attribute(:submitted_at, Date.today)
        visit service_calendar_service_request_path service_request.id
        wait_for_javascript_to_finish
        expect(page).to_not have_content('Save as Draft')
      end
    end
  end
end
