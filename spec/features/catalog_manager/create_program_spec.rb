require 'spec_helper'

feature 'create new program', :js => true do
  scenario 'user creates a new program' do
    default_catalog_manager_setup
    
    click_link('Create New Program')

    get_alert_window do |prompt|
      prompt.send_keys("The Program")
      prompt.accept

      click_link('The Program')

      # General Information fields
      fill_in 'program_abbreviation', :with => 'PTP'
      fill_in 'program_order', :with => '2'
      fill_in 'program_description', :with => 'Description'
      # Subsidy Information fields
      within '#pricing' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
      fill_in 'program_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'program_subsidy_map_attributes_max_dollar_cap', :with => '65'

      page.execute_script("$('#save_button').click();")
      page.should have_content( 'The Program saved successfully' )
    end
  end
  
end
