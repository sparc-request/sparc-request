require 'spec_helper'

describe 'edit an institution', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link('Medical University of South Carolina')
  end

  context 'successfully update an existing institution' do
    
    it "should successfully edit and save the institution" do
      
      # General Information fields
      fill_in 'institution_abbreviation', :with => 'GreatestInstitution'
      fill_in 'institution_description', :with => 'Description'
      fill_in 'institution_ack_language', :with => 'Language'
      fill_in 'institution_order', :with => '1'
      select('blue', :from => 'institution_css_class')
      uncheck('institution_is_available')
      
      first("#save_button").click
      page.should have_content( 'Medical University of South Carolina saved successfully' )
    end

    context "editing status options" do

      before :each do
        @institution = Organization.where(abbreviation: "MUSC").first
        wait_for_javascript_to_finish
      end

      it "should get the default statuses" do
        @institution.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "get_a_quote" => "Get a Quote", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#institution_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        
        @institution.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#institution_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish

        @institution.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end

    context "adding and removing tags" do

      before :each do
        @institution = Organization.where(abbreviation: "MUSC").first
        wait_for_javascript_to_finish
      end

      it "should get the tag that is entered" do
        fill_in 'institution_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish

        @institution.tag_list.should eq(["The Doctor"])
      end

      it "should delete the tag once the field is cleared and saved" do
        fill_in 'institution_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish
        fill_in 'institution_tag_list', :with => ''
        first("#save_button").click
        wait_for_javascript_to_finish

        @institution.tag_list.should eq([])
      end

      it "should create an array of tags if more than one is entered" do
        fill_in 'institution_tag_list', :with => 'The Doctor, Dalek, Amy Pond'
        first("#save_button").click
        wait_for_javascript_to_finish

        @institution.tag_list.should eq(['The Doctor', 'Dalek', 'Amy Pond'])
      end
    end
  end
end