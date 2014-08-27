require 'spec_helper'

feature 'create new core', :js => true do
  scenario 'user creates a new core' do
    # build_service_request
    default_catalog_manager_setup

    program = Program.find_by_name('Office of Biomedical Informatics')
    within("#PROGRAM#{program.id}") do
      click_link('Create New Core')
    end

    get_alert_window do |prompt|
      prompt.send_keys("Par for the Core")
      prompt.accept

      click_link('Par for the Core')

      # General Information fields
      wait_for_javascript_to_finish
      
      fill_in 'core_abbreviation', :with => 'PTP'
      fill_in 'core_order', :with => '2'
      # Subsidy Information fields
      within '#pricing' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
      fill_in 'core_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'core_subsidy_map_attributes_max_dollar_cap', :with => '65'

      page.execute_script("$('#save_button').click();")
      page.should have_content( 'Par for the Core saved successfully' )
    end
  end
  
  scenario ': a user with only access to this program can see links for: Create New Core and Create New Service' do
    create_default_data
    
    identity = Identity.create(last_name: 'Miller', first_name: 'Robert', ldap_uid: 'rmiller@musc.edu', email:  'rmiller@musc.edu', password: 'p4ssword',password_confirmation: 'p4ssword',  approved: true )
    identity.save!

    program = Program.find_by_name('Office of Biomedical Informatics')
    
    cm = CatalogManager.create( organization_id: program.id, identity_id: identity.id, )
    cm.save!

    login_as(Identity.find_by_ldap_uid('rmiller@musc.edu'))
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    expect(page).to have_content('Create New Core')
    expect(page).to have_content('Create New Service')
  end
    
end
