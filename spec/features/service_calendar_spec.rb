require 'spec_helper'

describe "service calendar" do

  describe "one time fees" do
    build_service_request_with_project()

    it "should calculate the totals", :js => true do
      visit service_calendar_service_request_path service_request.id
      sleep 1
      find(".total_#{line_item.id}").text().should eq("$50.00") # 5 quantity 1 unit per
    end
  end

  describe "per patient per visit" do
    build_service_request_with_project()

    before :each do
      visit service_calendar_service_request_path service_request.id
      sleep 1
    end

    describe "template tab" do
      it "totals should be 0 when visits aren't checked", :js => true do
        find(".pp_total_direct_cost").text().should eq("$0.00")
        find(".pp_total_indirect_cost").text().should eq("$0.00")
        find(".pp_total_cost").text().should eq("$0.00")
      end

      it "should not show the full rate if your cost > full rate", :js => true do
        find(".service_rate_#{line_item2.id}").text().should eq("")
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
          click_link "check_row_#{line_item2.id}"
          sleep 2
          find(".total_#{line_item2.id}").text().should eq('$300.00') # Probably a better way to do this. But this should be the 10 visits added together.
        end

        it "should uncheck all visits", :js => true do
          click_link "check_row_#{line_item2.id}"
          sleep 2
          click_link "check_row_#{line_item2.id}"
          sleep 2
          find(".total_#{line_item2.id}").text().should eq('$0.00') # Probably a better way to do this.
        end
      end

      describe "selecting check column button" do
        it "should check all visits in the given column", :js => true do
          find("Visit 2").find_link("Check All").click()
          sleep 2
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
  end
end