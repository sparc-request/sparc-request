require 'spec_helper'

feature 'create new provider' do
  background do
    default_catalog_manager_setup
  end 
  
  scenario 'user creates a new provider', :js => true do
    click_link('Create New Provider')

    prompt = page.driver.browser.switch_to.alert
    prompt.send_keys('Polly The Provider')
    prompt.accept

    click_link('Polly The Provider')

    # General Information fields
    fill_in 'provider_abbreviation', :with => 'PTP'
    fill_in 'provider_order', :with => '2'
    fill_in 'provider_description', :with => 'Description'

    # Subsidy Information fields
    fill_in 'provider_subsidy_map_attributes_max_percentage', :with => '55.5'
    fill_in 'provider_subsidy_map_attributes_max_dollar_cap', :with => '65'

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Polly The Provider saved successfully' )
  end
  
end