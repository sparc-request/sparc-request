require 'spec_helper'

feature 'edit a program', :js => true do
  scenario 'successfully update an existing program' do
    default_catalog_manager_setup
    
    click_link('Office of Biomedical Informatics')

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

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Office of Biomedical Informatics saved successfully' )
  end
  
end