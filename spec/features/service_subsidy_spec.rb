require 'spec_helper'
#include 'ServiceCalendarHelper'

describe "Subsidy Page" do
  build_service_request_with_project


  before :each do
    add_visits
    visit service_subsidy_service_request_path service_request.id
    sleep 1
    sign_in
    sleep 1
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


    describe "filling out the form" do
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
        find(".subsidy_percent_#{sub_service_request.id}").text.gsub!('%', '').to_f.should eq((@total - @contribution) / @total)
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