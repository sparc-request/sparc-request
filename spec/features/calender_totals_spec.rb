require 'spec_helper'

describe "calender totals" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:line_item3) { FactoryGirl.create(:line_item, id: 123456789, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }
  

  before :each do
    service_request.reload
    visit service_calendar_service_request_path service_request.id

  end

  after :each do
    wait_for_javascript_to_finish
  end


  describe "one time fees" do
    
    it "should calculate the totals", :js => true do
      find(".total_#{line_item3.id}").should have_exact_text("$50.00") # 5 quantity 1 unit per
    end
  end

  describe "display rates" do

    it "should show the full rate when full rate > your cost", :js => true do
      find(".service_rate_#{line_item3.id}").should have_exact_text("$20.00")
    end
  end

  describe "displaying totals" do
    it "totals should be 0 when visits aren't checked", :js => true do
      wait_for_javascript_to_finish
      first(".pp_max_total_direct_cost").text().should have_exact_text("$0.00")
      if USE_INDIRECT_COST
        find(".pp_total_indirect_cost").text().should have_exact_text("$0.00")
      end
      first(".pp_total").text().should have_exact_text("$0.00")
    end

    it "should update total costs when a visit is checked", :js => true do
      visit_id = arm1.line_items_visits.first.visits[1].id
      page.check("visits_#{visit_id}")
      first(".total_#{arm1.line_items_visits.first.id}").should have_exact_text("$30.00")
    end

    it "should change visits when -> is clicked", :js => true do
      click_link("->")
      retry_until {
        find("#arm_#{arm1.id}_visit_name_6").should have_value("Visit 6")
      }
    end
  end
end
