require 'spec_helper'

describe "service calendar" do
  let_there_be_lane
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
      find(".service_rate_#{line_item2.id}").should have_exact_text("")
    end

    it "should show the full rate when full rate > your cost", :js => true do
      find(".service_rate_#{line_item.id}").should have_exact_text("$20.00")
    end
  end

  describe "one time fees" do
    it "should calculate the totals", :js => true do
      find(".total_#{line_item.id}").should have_exact_text("$50.00") # 5 quantity 1 unit per
    end
  end

  describe "per patient per visit" do
    describe "template tab" do
      it "totals should be 0 when visits aren't checked", :js => true do
        find(".pp_total_direct_cost").text().should have_exact_text("$0.00")
        find(".pp_total_indirect_cost").text().should have_exact_text("$0.00")
        find(".pp_total_cost").text().should have_exact_text("$0.00")
      end

      it "should update total costs when a visit is checked", :js => true do
        visit_id = line_item2.visits[1].id
        remove_from_dom(".total_#{line_item2.id}")
        page.check("visits_#{visit_id}")
        find(".total_#{line_item2.id}").should have_exact_text("$30.00")
      end

      it "should change visits when -> is clicked", :js => true do
        click_link("->")
        page.should have_content("Visit 6")
      end

      describe "selecting check row button" do
        it "should check all visits", :js => true do
          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          find(".total_#{line_item2.id}").should have_exact_text('$300.00') # Probably a better way to do this. But this should be the 10 visits added together.
        end

        it "should uncheck all visits", :js => true do
          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          find(".total_#{line_item2.id}").should have_exact_text('$300.00') # this is here to wait for javascript to finish

          remove_from_dom(".total_#{line_item2.id}")
          click_link "check_row_#{line_item2.id}_template"
          find(".total_#{line_item2.id}").should have_exact_text('$0.00') # Probably a better way to do this.
        end
      end

      describe "selecting check column button" do
        it "should check all visits in the given column", :js => true do
          click_link "check_all_column_3"
          wait_for_javascript_to_finish

          find("#visits_#{line_item2.visits[2].id}").checked?.should eq(true)
        end

        it "should uncheck all visits in the given column", :js => true do
          click_link "check_all_column_3"
          wait_for_javascript_to_finish

          find("#visits_#{line_item2.visits[2].id}").checked?.should eq(true)

          click_link "check_all_column_3"
          wait_for_javascript_to_finish

          find("#visits_#{line_item2.visits[2].id}").checked?.should eq(false)
        end
      end

      describe "changing subject count" do
        before :each do
          visit_id = line_item2.visits[1].id
          page.check("visits_#{visit_id}")
          select "2", :from => "line_item_#{line_item2.id}_count"
        end

        it "should change total costs", :js => true do
          find('.pp_total_direct_cost').should have_exact_text('$60.00')
        end

        it "should not change maximum totals", :js => true do
          find('.pp_max_total_direct_cost').should have_exact_text("$30.00")
        end
      end
    end

    describe "billing strategy tab" do
      before :each do
        click_link "billing_strategy_tab"
      end

      describe "selecting check all row button" do
        it "should overwrite the quantity in research billing box", :js => true do
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
          click_link "check_row_#{line_item2.id}_billing_strategy"
          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").value().should eq("10")
        end
      end

      describe "increasing the 'R' billing quantity" do
        it "should increase the total cost", :js => true do
          # Remove these elements so that fill_in can't fill in the "old" fields
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_insurance_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_effort_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_research_billing_qty').remove()")

          click_link "check_row_#{line_item2.id}_billing_strategy"

          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").set("")
          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").click()
          fill_in( "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10)
          find("#visits_#{line_item2.visits[1].id}_insurance_billing_qty").click()

          all('.pp_max_total_direct_cost').each do |x|
            if x.visible?
              x.should have_exact_text("$570.00")
            end
          end
        end

        it "should update each visits maximum costs", :js => true do
          # Remove these elements so that fill_in can't fill in the "old" fields
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_insurance_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_effort_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_research_billing_qty').remove()")
          page.execute_script("$('.visit_column_2.max_direct_per_patient').remove()")

          click_link "check_row_#{line_item2.id}_billing_strategy"

          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").set("")
          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").click()
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
          find("#visits_#{line_item2.visits[1].id}_insurance_billing_qty").click()

          wait_for_javascript_to_finish

          sleep 3 # TODO: ugh: I got rid of all the sleeps, but I can't get rid of this one

          all('.visit_column_2.max_direct_per_patient').each do |x|
            if x.visible?
              x.should have_exact_text("$300.00")
            end
          end

          all('.visit_column_2.max_indirect_per_patient').each do |x|
            if x.visible?
              x.should have_exact_text "$150.00"
            end
          end
        end
      end

      describe "increasing the '%' or 'T' billing quantity" do
        it "should not increase the total cost", :js => true do
          # Remove these elements so that fill_in can't fill in the "old" fields
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_insurance_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_effort_billing_qty').remove()")
          page.execute_script("$('#visits_#{line_item2.visits[1].id}_research_billing_qty').remove()")

          # Now check the row; the fields we just deleted will be
          # re-created
          click_link "check_row_#{line_item2.id}_billing_strategy"

          # Putting values in these fields should not increase the total
          # cost
          fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 10
          find("#visits_#{line_item2.visits[1].id}_effort_billing_qty").click()

          fill_in "visits_#{line_item2.visits[1].id}_effort_billing_qty", :with => 10
          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").click()

          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 1
          find("#visits_#{line_item2.visits[1].id}_insurance_billing_qty").click()

          all('.pp_max_total_direct_cost').each do |x|
            if x.visible?
              x.should have_exact_text "$300.00"
            end
          end
        end
      end
    end

    describe "quantity tab" do
      it "should add all billing quantities together", :js => true do
        click_link "billing_strategy_tab"

        # Remove these elements so that fill_in can't fill in the "old" fields
        page.execute_script("$('#visits_#{line_item2.visits[1].id}_insurance_billing_qty').remove()")
        page.execute_script("$('#visits_#{line_item2.visits[1].id}_effort_billing_qty').remove()")
        page.execute_script("$('#visits_#{line_item2.visits[1].id}_research_billing_qty').remove()")

        click_link "check_row_#{line_item2.id}_billing_strategy"

        fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
        fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 10
        fill_in "visits_#{line_item2.visits[1].id}_effort_billing_qty", :with => 10

        click_link "quantity_tab"

        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.should have_exact_text('30')
          end
        end
      end
    end

    describe "pricing tab" do
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
        fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 5
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

