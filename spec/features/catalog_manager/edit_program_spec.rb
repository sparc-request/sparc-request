require 'spec_helper'

describe 'edit a program', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link('Office of Biomedical Informatics')
  end

  context 'successfully update an existing program' do

    it "should successfully edit and save the program" do
      # General Information fields
      fill_in 'program_abbreviation', :with => 'PTP'
      fill_in 'program_order', :with => '2'
      fill_in 'program_description', :with => 'Description'
      fill_in 'program_ack_language', :with => 'Language'
      check 'program_process_ssrs'
      check 'program_is_available'    
      # Subsidy Information fields
      fill_in 'program_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'program_subsidy_map_attributes_max_dollar_cap', :with => '65'

      first("#save_button").click
      page.should have_content( 'Office of Biomedical Informatics saved successfully' )
    end

    context "editing status options" do

      before :each do
        @program = Organization.where(abbreviation: "Informatics").first
        wait_for_javascript_to_finish
      end

      it "should get the default statuses" do
        @program.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "obtain_research_pricing" => "Obtain Research Pricing", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#program_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        @program.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#program_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        @program.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end
  end
end