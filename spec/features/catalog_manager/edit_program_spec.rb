require 'spec_helper'

describe 'edit a program', :js => true do

  before :each do
    default_catalog_manager_setup
    Tag.create(:name => "ctrc")
    Tag.create(:name => "clinical work fulfillment")
    click_link('Office of Biomedical Informatics')
    wait_for_javascript_to_finish
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

      first("#save_button").click
      page.should have_content( 'Office of Biomedical Informatics saved successfully' )
    end

    context "adding and removing tags" do
      before :each do
        @program = Organization.where(abbreviation: "Informatics").first
        wait_for_javascript_to_finish
      end

      it "should list the tags" do
        page.should have_css("#program_tag_list_ctrc")
      end

      it "should be able to check a tag box" do
        find('#program_tag_list_ctrc').click
        first("#save_button").click
        page.should have_content('Office of Biomedical Informatics saved successfully')
        find('#program_tag_list_ctrc').should be_checked
        @program.tag_list.should eq(['ctrc'])
      end
    end

    context "editing status options" do
      before :each do
        @program = Organization.where(abbreviation: "Informatics").first
        find('#available_statuses_fieldset').click
        sleep 3
      end

      it "should get the default statuses" do
        @program.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "get_a_quote" => "Get a Quote", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
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

    context "viewing user rights section" do
      it "should show user rights section" do
        find('#user_rights').click
        sleep 3
        find('#su_info').should be_visible
      end
    end

    context "viewing cwf section" do
      it "should not display cwf by default" do
        page.should_not have_css('#cwf_fieldset')
      end

      it "should display cwf if tagged with cwf" do
        find('#program_tag_list_clinical_work_fulfillment').click
        first("#save_button").click
        wait_for_javascript_to_finish
        page.should have_content('Office of Biomedical Informatics saved successfully')
        click_link('Office of Biomedical Informatics')
        wait_for_javascript_to_finish

        find('#cwf_fieldset').should be_visible
        find('#cwf_fieldset').click
        sleep 3
        first('#cwf_fieldset fieldset').should be_visible
      end
    end

    context "pricing section" do
      before :each do
        find('#pricing').click
        sleep 3
      end

      it "shoulld show the pricing section" do
        first('#pricing fieldset').should be_visible
      end

      it "should have a functional subsidy section" do
        # Subsidy Information fields
        fill_in 'program_subsidy_map_attributes_max_percentage', :with => '55.5'
        fill_in 'program_subsidy_map_attributes_max_dollar_cap', :with => '65'

        first("#save_button").click
        page.should have_content( 'Office of Biomedical Informatics saved successfully' )
      end
    end
  end
end