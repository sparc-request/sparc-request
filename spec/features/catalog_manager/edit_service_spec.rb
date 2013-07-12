require 'spec_helper'

feature 'edit a service' do
  background do
    default_catalog_manager_setup
  end
  
  scenario 'successfully update a service under a program', :js => true do
    click_link('Human Subject Review')

    # Program Select should defalut to parent Program
    within ('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end

    # Core Select should default to None
    within ('#service_core') do
      page.should have_content('None')
    end
  
    fill_in 'service_abbreviation', :with => 'TestService'
    fill_in 'service_description', :with => 'Description'
    fill_in 'service_order', :with => '1'
    check 'service_is_available'

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'Human Subject Review saved successfully' )
  end

  scenario 'successfully update a service under a core', :js => true do
    click_link('MUSC Research Data Request (CDW)')
    
    # Program Select should defalut to parent Program
    within ('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end

    # Core Select should default to parent Core
    within ('#service_core') do
      page.should have_content('Clinical Data Warehouse')
    end
  
    fill_in 'service_abbreviation', :with => 'TestServiceTwo'
    fill_in 'service_description', :with => 'DescriptionTwo'
    fill_in 'service_order', :with => '2'
    check 'service_is_available'

    page.execute_script("$('#save_button').click();")
    page.should have_content( 'MUSC Research Data Request (CDW) saved successfully' )
  end

  scenario "successfully add/remove associated surveys", :js => true do
    click_link('MUSC Research Data Request (CDW)')
    
    # Program Select should defalut to parent Program
    within ('#service_program') do
      page.should have_content('Office of Biomedical Informatics')
    end

    # Core Select should default to parent Core
    within ('#service_core') do
      page.should have_content('Clinical Data Warehouse')
    end

    within ('#associated_survey_info') do
      #no survey selected 
      
      click_button 'New Associated Survey'
      a = page.driver.browser.switch_to.alert
      a.text.should eq "No survey selected"
      a.accept

      #select survey and add
      select 'Version 0', :from => 'new_associated_survey'
      click_button 'New Associated Survey'
      wait_for_javascript_to_finish
      page.should have_content('System Satisfaction survey - Version 0')

      #remove survey
      page.find('.associated_survey_delete').click
      
      a = page.driver.browser.switch_to.alert
      a.text.should eq "Are you sure you want to remove this Associated Survey?"
      a.accept

      wait_for_javascript_to_finish
      page.should_not have_content('System Satisfaction survey - Version 0')
    end
  end
end
