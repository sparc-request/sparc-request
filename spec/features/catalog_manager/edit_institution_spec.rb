require 'spec_helper'

feature 'edit an institution', :js => true do
  scenario 'successfully update an existing institution' do
    default_catalog_manager_setup

    click_link('Medical University of South Carolina')
    
    # General Information fields
    fill_in 'institution_abbreviation', :with => 'GreatestInstitution'
    fill_in 'institution_description', :with => 'Description'
    fill_in 'institution_ack_language', :with => 'Language'
    fill_in 'institution_order', :with => '1'
    select('blue', :from => 'institution_css_class')
    uncheck('institution_is_available')
    
    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Medical University of South Carolina saved successfully' )
  end
  
end