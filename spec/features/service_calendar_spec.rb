require 'spec_helper'

describe "service calendar" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    visit service_calendar_service_request_path service_request.id
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "display rates" do
    it "should not show the full rate if your cost > full rate", :js => true do
      first(".service_rate_#{arm1.visit_groupings.first.id}").should have_exact_text("")
    end
  end

  describe "per patient per visit" do
    describe "template tab" do


      describe "selecting check row button" do
        it "should check all visits", :js => true do
          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          wait_for_javascript_to_finish
          find(".total_#{line_item2.id}").should have_exact_text('$150.00') # Probably a better way to do this. But this should be the 10 visits added together.
        end

        it "should uncheck all visits", :js => true do
          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          wait_for_javascript_to_finish
          find(".total_#{line_item2.id}").should have_exact_text('$150.00') # this is here to wait for javascript to finish

          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          wait_for_javascript_to_finish
          find(".total_#{line_item2.id}").should have_exact_text('$0.00') # Probably a better way to do this.
        end
      end

      describe "selecting check column button" do

        it "should check all visits in the given column", :js => true do
          wait_for_javascript_to_finish
          first("#check_all_column_3").click
          wait_for_javascript_to_finish

          find("#visits_#{arm1.visit_groupings.first.visits[2].id}").checked?.should eq(true)
        end

        it "should uncheck all visits in the given column", :js => true do
          wait_for_javascript_to_finish
          first("#check_all_column_3").click        
          wait_for_javascript_to_finish
          

          find("#visits_#{arm1.visit_groupings.first.visits[2].id}").checked?.should eq(true)
          wait_for_javascript_to_finish
          first("#check_all_column_3").click
          wait_for_javascript_to_finish

          find("#visits_#{arm1.visit_groupings.first.visits[2].id}").checked?.should eq(false)
        end
      end

      describe "changing subject count" do
        before :each do
          visit_id = arm1.visit_groupings.first.visits[1].id
          page.check("visits_#{visit_id}")
          select "2", :from => "visit_grouping_#{arm1.visit_groupings.first.id}_count"
        end

        it "should not change maximum totals", :js => true do
          find(".pp_max_total_direct_cost.arm_#{arm1.id}").should have_exact_text("$30.00")
        end
      end
    end

    describe "billing strategy tab" do
      before :each do
        click_link "billing_strategy_tab"
        @visit_id = arm1.visit_groupings.first.visits[1].id
      end

      describe "selecting check all row button" do

        it "should overwrite the quantity in research billing box", :js => true do
          fill_in "visits_#{@visit_id}_research_billing_qty", :with => 10
          wait_for_javascript_to_finish
          click_link "check_row_#{line_item2.id}_billing_strategy"
          wait_for_javascript_to_finish
          find("#visits_#{@visit_id}_research_billing_qty").should have_value("10")
        end
      end

      describe "increasing the 'R' billing quantity" do

        # before :each do
        #   @visit_id = arm1.visit_groupings.first.visits[1].id
        # end

        it "should increase the total cost", :js => true do
         
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

        it "should update each visits maximum costs", :js => true do

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
          @visit_id = arm1.visit_groupings.first.visits[1].id
        end

        it "should not increase the total cost", :js => true do

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
        @visit_id = arm1.visit_groupings.first.visits[1].id
      end

      it "should add all billing quantities together", :js => true do
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

    describe "pricing tab" do

      before :each do
        @visit_id = arm1.visit_groupings.first.visits[1].id
      end

      it "should be blank if the visit is not checked", :js => true do
        click_link "pricing_tab"
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.should have_exact_text('')
          end
        end
      end

      it "should show total price for that visit", :js => true do
        click_link "billing_strategy_tab"
        fill_in "visits_#{@visit_id}_research_billing_qty", :with => 5
        click_link "pricing_tab"
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.should have_exact_text('150.00')
          end
        end
      end
    end
  end
end

