require 'spec_helper'

describe 'edit a provider', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link('South Carolina Clinical and Translational Institute (SCTR)')
  end
   
  context 'successfully update an existing provider'  do
       
    it "should successfully edit and save the provider" do
      # General Information fields
      fill_in 'provider_abbreviation', :with => 'PTP'
      fill_in 'provider_description', :with => 'Description'
      fill_in 'provider_ack_language', :with => 'Language'
      fill_in 'provider_order', :with => '2'
      select('orange', :from => 'provider_css_class')
      check('provider_process_ssrs')
      check('provider_is_available')    

      # Subsidy Information fields
      fill_in 'provider_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'provider_subsidy_map_attributes_max_dollar_cap', :with => '65'

      first('#save_button').click
      page.should have_content( 'South Carolina Clinical and Translational Institute (SCTR) saved successfully' )
    end

    context "editing status options" do

      before :each do
        @provider = Organization.where(abbreviation: "SCTR1").first
        wait_for_javascript_to_finish
      end

      it "should get the default statuses" do
        @provider.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "obtain_research_pricing" => "Obtain Research Pricing", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#provider_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        @provider.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#provider_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        @provider.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end
  end
end