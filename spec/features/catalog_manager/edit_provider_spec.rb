require 'spec_helper'

feature 'edit a provider' do
  background do
    default_catalog_manager_setup
  end 
  
  scenario 'successfully update an existing provider', :js => true do
    click_link('South Carolina Clinical and Translational Institute (SCTR)')

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

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'South Carolina Clinical and Translational Institute (SCTR) saved successfully' )
  end
  
end