require 'spec_helper'

describe "subsidy page" do
  build_service_request_with_project


  before :each do
    add_visits
    visit service_subsidy_service_request_path service_request.id
    sleep 1
    sign_in
    sleep 1
  end

  describe "Subsidy Map is not preset" do
    it 'Should allow PI Contribution to be set', :js => true do
      page.should_not have_css("input.pi-contribution[disabled=disabled]")
    end
    it 'Should save PI Contribution', :js => true do
      total = sub_service_request.direct_cost_total
      max = program.subsidy_map.max_dollar_cap
      amount = total - max + 5
      find('.pi-contribution').set(amount)
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      sleep 2
      sub_service_request.subsidy.pi_contribution.should eq(Service.dollars_to_cents(amount.to_s))
    end
  end

end