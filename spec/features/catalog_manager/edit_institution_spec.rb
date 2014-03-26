require 'spec_helper'

describe 'edit an institution', :js => true do


  before :each do
    default_catalog_manager_setup
    Tag.create(:name => "ctrc")
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


    context "adding and removing tags" do
      before :each do
        @institution = Organization.where(abbreviation: "MUSC").first
        wait_for_javascript_to_finish
      end

      it "should list the tags" do
        page.should have_css("#institution_tag_list_ctrc")
      end

      it "should be able to check a tag box" do
        find('#institution_tag_list_ctrc').click
        first("#save_button").click
        page.should have_content( 'Medical University of South Carolina saved successfully' )
        find('#institution_tag_list_ctrc').should be_checked
        @institution.tag_list.should eq(['ctrc'])
      end
    end


    context "viewing user rights section" do
      it "should show user rights section" do
        find('#user_rights').click
        sleep 3
        find('#su_info').should be_visible
      end
    end
  end
end