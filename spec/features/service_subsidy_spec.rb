require 'spec_helper'
#include 'ServiceCalendarHelper'

describe "subsidy page" do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_project

  # describe "no subsidy available" do
  #   before :each do
  #     add_visits
  #     visit service_subsidy_service_request_path service_request.id
  #     sleep 2
  #   end
  #   it 'should not have any subsidies', :js => true do
  #     page.should_not have_css(".subsidy-item")
  #   end
  # end

  before :each do
    add_visits
    subsidy_map = FactoryGirl.create(:subsidy_map, organization_id: program.id, max_dollar_cap: 775.00, max_percentage: 50.00)
    program.update_attribute(:subsidy_map, subsidy_map)
    visit service_subsidy_service_request_path service_request.id
  end

  describe "Subsidy is not overridden" do
    it 'Should allow PI Contribution to be set', :js => true do
      page.should_not have_css("input.pi-contribution[disabled=disabled]")
    end

    describe "leaving the form blank" do
      it 'should be fine with that', :js => true do
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        sleep 2
        sub_service_request.subsidy.should eq(nil)
      end
    end

    describe "filling in with wrong values" do
      before :each do
        @total = (sub_service_request.direct_cost_total / 100)
        @contribution = (@total - program.subsidy_map.max_dollar_cap) - 100
        find('.pi-contribution').set(@contribution)
        sleep 2
        find('.select-project-view').click
        sleep 2
      end
      it 'should reject to high an amount', :js => true do
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        page.should have_text("cannot exceed maximum dollar amount")
      end

      it 'should reject too high a percentage', :js => true do
        
      end
    end

    describe "filling in with correct values" do
      before :each do
        @total = (sub_service_request.direct_cost_total / 100)
        @contribution = @total - program.subsidy_map.max_dollar_cap
        find('.pi-contribution').set(@contribution)
        sleep 2
        find('.select-project-view').click
        sleep 2
      end

      it 'Should save PI Contribution', :js => true do
        find(:xpath, "//a/img[@alt='Savecontinue']/..").click
        sleep 2
        sub_service_request.subsidy.pi_contribution.should eq((@contribution * 100).to_i)
      end

      it 'should adjust requested funding correctly', :js => true do
        find(".requested_funding_#{sub_service_request.id}").text.gsub!('$', '').to_f.should eq(@total - @contribution)
      end

      it 'should adjust subsidy percent correctly', :js => true do
        find(".subsidy_percent_#{sub_service_request.id}").text.gsub!('%', '').to_f.should eq (((@total - @contribution) / @total) * 100).round(1)
      end
    end
  end

  describe "Subsidy is overridden" do
    it 'Should NOT allow PI Contribution to be set', :js => true do
      subsidy = FactoryGirl.create(:subsidy, sub_service_request_id: sub_service_request.id, pi_contribution: sub_service_request.direct_cost_total, overridden: true)
      visit service_subsidy_service_request_path service_request.id
      sleep 2
    end
  end

end
