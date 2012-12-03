require 'spec_helper'

describe "service calendar" do

  describe "per patient per visit" do
    build_service_request()
    build_project()

    it "the totals should be 0 when visits aren't checked", :js => true do
      visit service_calendar_service_request_path service_request.id
      sleep 1
      find(".pp_total_direct_cost").text().should eq("$0.00")
      find(".pp_total_indirect_cost").text().should eq("$0.00")
      find(".pp_total_cost").text().should eq("$0.00")
    end

    it "should not show the full rate if your cost > full rate", :js => true do
      visit service_calendar_service_request_path service_request.id
      sleep 1
      find(".service_rate_#{line_item2.id}").text().should eq("")
    end

    it "checking a visit should update total costs", :js => true do
      visit service_calendar_service_request_path service_request.id
      visit_id = line_item2.visits[1].id
      page.check("visits_#{visit_id}")
      sleep 1
      find(".total_#{line_item2.id}").text().should eq("$30.00")
    end
  end

  describe "one time fees" do
    build_service_request()
    build_project()

    it "should calculate the totals", :js => true do
      visit service_calendar_service_request_path service_request.id
      find(".total_#{line_item.id}").text().should eq("$50.00") # 5 quantity 1 unit per
      sleep 1
    end

  end
end