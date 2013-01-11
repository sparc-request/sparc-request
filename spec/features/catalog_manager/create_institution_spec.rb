require 'spec_helper'

feature 'create new institution', :js => true do
  before :each do
    default_catalog_manager_setup
  end

  scenario 'user creates a new institution' do
    click_link('Create New Institution')
    get_alert_window do |prompt|
      prompt.send_keys("Greatest Institution")
      prompt.accept

      click_link( 'Greatest Institution' )
      
      fill_in 'institution_abbreviation', :with => 'GreatestInstitution'
      fill_in 'institution_order', :with => '1'
      fill_in 'institution_description', :with => ''
      
      page.execute_script("$('#save_button').click();")
      page.should have_content( 'Greatest Institution saved successfully' )
    end
  end
end
