require 'spec_helper'

describe 'edit a program', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link('Office of Biomedical Informatics')
    wait_for_javascript_to_finish
  end

  context 'successfully update an existing program' do

    before :each do
      @program = Organization.where(abbreviation: "Informatics").first
      wait_for_javascript_to_finish
    end

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

    context "adding and removing tags" do

      it "should get the tag that is entered" do
        fill_in 'program_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish

        @program.tag_list.should eq(["The Doctor"])
      end

      it "should delete the tag once the field is cleared and saved" do
        fill_in 'program_tag_list', :with => 'The Doctor'
        first("#save_button").click
        wait_for_javascript_to_finish
        fill_in 'program_tag_list', :with => ''
        first("#save_button").click
        wait_for_javascript_to_finish

        @program.tag_list.should eq([])
      end

      it "should create an array of tags if more than one is entered" do
        fill_in 'program_tag_list', :with => 'The Doctor, Dalek, Amy Pond'
        first("#save_button").click
        wait_for_javascript_to_finish

        @program.tag_list.should eq(['The Doctor', 'Dalek', 'Amy Pond'])
      end
    end

    context "adding and deleting super users" do

      it "should add a new super user" do
        fill_in "new_su", :with => "Leonard"
        wait_for_javascript_to_finish
        page.find('a', :text => "Jason Leonard (leonarjp@musc.edu)", :visible => true).click()
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish

        page.should have_content("Jason Leonard")
      end

      it "should delete a super user" do
        fill_in "new_su", :with => "Leonard"
        wait_for_javascript_to_finish
        page.find('a', :text => "Jason Leonard (leonarjp@musc.edu)", :visible => true).click()
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish

        # This overrides the javascript confirm dialog
        page.evaluate_script('window.confirm = function() { return true; }')

        find('.su_delete').click
        wait_for_javascript_to_finish
        page.should_not have_content("Jason Leonard")
      end
    end
  end
end