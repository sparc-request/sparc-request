require 'spec_helper'

describe "study schedule", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits
    visit study_tracker_sub_service_request_path sub_service_request.id
    arm1.reload
    arm2.reload
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "back link" do
    it "should take you back to study tracker landing page" do
      click_link("Return to Clinical Work Fulfillment")
      wait_for_javascript_to_finish
      current_path.should eq("/study_tracker")
    end
  end

  describe "display rates" do
    it "should not show the full rate if your cost > full rate" do
      first(".service_rate_#{arm1.line_items_visits.first.id}").should have_exact_text("")
    end
  end

  describe "per patient per visit" do

    describe "template tab" do

      describe "selecting check row button" do

        it "should check all visits" do
          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish
          arm1.line_items_visits.first.visits.each do |visit|
            visit.research_billing_qty.should eq(1)
          end
        end

        it "should uncheck all visits" do
          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish

          click_link "check_row_#{arm1.line_items_visits.first.id}_template"
          wait_for_javascript_to_finish
          arm1.line_items_visits.first.visits.each do |visit|
            visit.research_billing_qty.should eq(0)
          end
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