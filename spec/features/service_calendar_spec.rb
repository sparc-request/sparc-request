require 'spec_helper'

describe "service calendar" do
  build_service_request_with_project()

  before :each do
    visit service_calendar_service_request_path service_request.id
    sign_in
    sleep 1
  end

  describe "display rates" do
    it "should not show the full rate if your cost > full rate", :js => true do
      find(".service_rate_#{line_item2.id}").text().should eq("")
    end

    it "should show the full rate when full rate > your cost", :js => true do
      find(".service_rate_#{line_item.id}").text().should eq("$20.00")
    end
  end

  describe "one time fees" do
    it "should calculate the totals", :js => true do
      find(".total_#{line_item.id}").text().should eq("$50.00") # 5 quantity 1 unit per
    end
  end

  describe "per patient per visit" do
    describe "template tab" do
      it "totals should be 0 when visits aren't checked", :js => true do
        find(".pp_total_direct_cost").text().should eq("$0.00")
        find(".pp_total_indirect_cost").text().should eq("$0.00")
        find(".pp_total_cost").text().should eq("$0.00")
      end

      it "should update total costs when a visit is checked", :js => true do
        visit_id = line_item2.visits[1].id
        page.check("visits_#{visit_id}")
        sleep 1
        find(".total_#{line_item2.id}").text().should eq("$30.00")
      end

      it "should change visits when -> is clicked", :js => true do
        click_link("->")
        sleep 1
        page.should have_content("Visit 6")
      end

      describe "selecting check row button" do
        it "should check all visits", :js => true do
          click_link "check_row_#{line_item2.id}_template"
          sleep 2
          find(".total_#{line_item2.id}").text().should eq('$300.00') # Probably a better way to do this. But this should be the 10 visits added together.
        end

        it "should uncheck all visits", :js => true do
          click_link "check_row_#{line_item2.id}_template"
          sleep 2
          click_link "check_row_#{line_item2.id}_template"
          sleep 2
          find(".total_#{line_item2.id}").text().should eq('$0.00') # Probably a better way to do this.
        end
      end

      describe "selecting check column button" do
        it "should check all visits in the given column", :js => true do
          click_link "check_all_column_3"
          sleep 2
          find("#visits_#{line_item2.visits[2].id}").checked?.should eq(true)
        end

        it "should uncheck all visits in the given column", :js => true do
          click_link "check_all_column_3"
          sleep 2
          click_link "check_all_column_3"
          sleep 2
          find("#visits_#{line_item2.visits[2].id}").checked?.should eq(false)
        end
      end

      describe "changing subject count" do
        before :each do
          visit_id = line_item2.visits[1].id
          page.check("visits_#{visit_id}")
          select "2", :from => "line_item_#{line_item2.id}_count"
          sleep 1
        end

        it "should change total costs", :js => true do
          find('.pp_total_direct_cost').text().should eq('$60.00')
        end

        it "should not change maximum totals", :js => true do
          find('.pp_max_total_direct_cost').text().should eq("$30.00")
        end
      end
    end

    describe "billing strategy tab" do
      before :each do
        click_link "billing_strategy_tab"
        sleep 3
      end

      describe "selecting check all row button" do
        it "should overwrite the quantity in research billing box", :js => true do
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
          click_link "check_row_#{line_item2.id}_billing_strategy"
          sleep 2
          find("#visits_#{line_item2.visits[1].id}_research_billing_qty").value().should eq("1")
        end
      end

      describe "increasing the 'R' billing quantity" do
        it "should increase the total cost", :js => true do
          click_link "check_row_#{line_item2.id}_billing_strategy"
          sleep 5
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
          fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 0
          sleep 3
          all('.pp_max_total_direct_cost').each do |x|
            if x.visible?
              x.text().should eq('$570.00')
            end
          end
        end

        it "should update each visits maximum costs", :js => true do
          click_link "check_row_#{line_item2.id}_billing_strategy"
          sleep 5
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
          fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 0
          sleep 3
          all('.visit_column_2.max_direct_per_patient').each do |x|
            if x.visible?
              x.text().should eq "$300.00"
            end
          end

          all('.visit_column_2.max_indirect_per_patient').each do |x|
            if x.visible?
              x.text().should eq "$150.00"
            end
          end
        end
      end

      describe "increasing the '%' or 'T' billing quantity" do
        it "should not increase the total cost", :js => true do
          click_link "check_row_#{line_item2.id}_billing_strategy"
          sleep 5
          fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 10
          fill_in "visits_#{line_item2.visits[1].id}_effort_billing_qty", :with => 10
          fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 1
          sleep 5
          all('.pp_max_total_direct_cost').each do |x|
            if x.visible?
              x.text().should eq('$300.00')
            end
          end
        end
      end
    end

    describe "quantity tab" do
      it "should add all billing quantities together", :js => true do
        click_link "billing_strategy_tab"
        click_link "check_row_#{line_item2.id}_billing_strategy"
        sleep 1
        fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 10
        fill_in "visits_#{line_item2.visits[1].id}_insurance_billing_qty", :with => 10
        fill_in "visits_#{line_item2.visits[1].id}_effort_billing_qty", :with => 10
        sleep 1
        click_link "quantity_tab"
        sleep 2
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.text().should eq('30')
          end
        end
      end
    end

    describe "pricing tab" do
      it "should be blank if the visit is not checked", :js => true do
        click_link "pricing_tab"
        sleep 1
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.text().should eq('')
          end
        end
      end

      it "should show total price for that visit", :js => true do
        click_link "billing_strategy_tab"
        sleep 1
        fill_in "visits_#{line_item2.visits[1].id}_research_billing_qty", :with => 5
        sleep 1
        click_link "pricing_tab"
        sleep 2
        all('.visit.visit_column_2').each do |x|
          if x.visible?
            x.text().should eq('$150.00')
          end
        end
      end
    end
  end
end