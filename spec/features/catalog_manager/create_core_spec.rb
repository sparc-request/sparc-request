require 'spec_helper'

feature 'create new core', :js => true do
  scenario 'user creates a new core' do
    build_service_request
    default_catalog_manager_setup

    program = Program.find_by_name('Office of Biomedical Informatics')
    within("#PROGRAM#{program.id}") do
      click_link('Create New Core')
    end

    prompt = page.driver.browser.switch_to.alert
    prompt.send_keys("Par for the Core")
    prompt.accept

    click_link('Par for the Core')

    # General Information fields
    fill_in 'core_abbreviation', :with => 'PTP'
    fill_in 'core_order', :with => '2'
    fill_in 'core_description', :with => 'Description'
    # Subsidy Information fields
    fill_in 'core_subsidy_map_attributes_max_percentage', :with => '55.5'
    fill_in 'core_subsidy_map_attributes_max_dollar_cap', :with => '65'

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Par for the Core saved successfully' )
  end
  
end