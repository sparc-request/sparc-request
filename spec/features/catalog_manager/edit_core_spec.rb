require 'spec_helper'

describe 'edit a core', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link('Clinical Data Warehouse')
  end

  context 'successfully update an existing core' do
   
    before :each do
      @core = Organization.where(abbreviation: "Clinical Data Warehouse").first
      wait_for_javascript_to_finish
    end

    it "should successfully edit and save the core" do  
      # General Information fields
      fill_in 'core_abbreviation', :with => 'PTP'
      fill_in 'core_order', :with => '2'
      fill_in 'core_description', :with => 'Description'
      # Subsidy Information fields
      fill_in 'core_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'core_subsidy_map_attributes_max_dollar_cap', :with => '65'

      page.execute_script("$('#save_button').click();")
      page.should have_content( 'Clinical Data Warehouse' )
    end

    context "editing status options" do

      it "should get the default statuses" do
        @core.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "get_a_quote" => "Get a Quote", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#core_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        @core.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#core_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        @core.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end

    context "adding and removing tags" do

      it "should get the tag that is entered" do
        fill_in 'core_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish

        @core.tag_list.should eq(["The Doctor"])
      end

      it "should delete the tag once the field is cleared and saved" do
        fill_in 'core_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish
        fill_in 'core_tag_list', :with => ''
        first("#save_button").click
        wait_for_javascript_to_finish

        @core.tag_list.should eq([])
      end

      it "should create an array of tags if more than one is entered" do
        fill_in 'core_tag_list', :with => 'The Doctor, Dalek, Amy Pond'
        first("#save_button").click
        wait_for_javascript_to_finish

        @core.tag_list.should eq(['The Doctor', 'Dalek', 'Amy Pond'])
      end
    end
  end
end