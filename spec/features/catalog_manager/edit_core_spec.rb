require 'spec_helper'

feature 'edit a core', :js => true do
  scenario 'successfully update an existing core' do
    default_catalog_manager_setup

    click_link('Clinical Data Warehouse')
    
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
  
end