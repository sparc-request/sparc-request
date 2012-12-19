require 'spec_helper'

feature 'effective and display date validations' do
  background do
    default_catalog_manager_setup
  end    
  
  scenario 'user cannot select the same effective date as an existing pricing_map', :js => true do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    click_button("Add Pricing Setup")
 
    page.execute_script("$('.ui-accordion-header').click()") 
 
    within('.ui-accordion') do
      find('.effective_date').click
      numerical_day = Date.today.strftime("%d").gsub(/^0/,'')
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
    end
 
    # This is the only way I could figure out how to test the text of the confirmation dialog
    prompt = page.driver.browser.switch_to.alert
    # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail
    if prompt.text == ('A pricing map already exists with that effective date.  Please choose another date.')
      prompt.accept
    end
  end
  
  scenario 'user cannot select the same display date as an existing pricing_map', :js => true do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    click_button("Add Pricing Setup")

    page.execute_script("$('.ui-accordion-header').click()") 

    within('.ui-accordion') do
      find('.display_date').click
      numerical_day = Date.today.strftime("%d").gsub(/^0/,'')
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
    end

    # This is the only way I could figure out how to test the text of the confirmation dialog
    prompt = retry_until { page.driver.browser.switch_to.alert }

    # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail    
    if prompt.text == ('A pricing map already exists with that display date.  Please choose another date.')
      prompt.accept
    end
  end
  

  scenario 'confirmation appears when a user selects an effective date that is before an existing effective date', :js => true do
    click_link("Office of Biomedical Informatics")
    click_button("Add Pricing Setup")

    page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()") 

    within('.ui-accordion > div:nth-of-type(2)') do
      find('.display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # go back one month
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15  
      sleep 1 # TODO: wait_for_javascript_to_finish doesn't work here
    end

    # This is the only way I could figure out how to test the text of the confirmation dialog
    prompt = retry_until { page.driver.browser.switch_to.alert }

    # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail    
    if prompt.text == ('This display date is before the display date of existing pricing maps, are you sure you want to do this?')
      prompt.dismiss # dismissed confirmation to avoid a second confirmation dialog, which capybara does not appear to handle
    end
    
  end

  # ## Need to figure out how to handle two confirmation dialogs in capybara

  # scenario 'a confirmation when selecting an effective date that is before existing pricing setup effective dates and
  #           a confirmation if it is before the effective dates of existing pricing maps.' do
  #   page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
  #   click_link("Office of Biomedical Informatics")
  #   click_button("Add Pricing Setup")
  #   page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()")
  #   within('.ui-accordion > div:nth-of-type(2)') do
  #     find('.display_date').click
  #     page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # move one month back
  #     page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # move one month back
  #     page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on the 15th
  #   end
  #   # This is the only way I could figure out how to test the text of the confirmation dialog
  #   prompt = page.driver.browser.switch_to.alert
  #   # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail    
  #   if prompt.text == ('You have selected a Effective date before an existing Effective date, are you sure you want to do this?')
  #     prompt.accept
  #   end
  #   # # This is the only way I could figure out how to test the text of the confirmation dialog
  #   # prompt2 = page.driver.browser.switch_to.alert
  #   # # # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail    
  #   # if prompt2.text == ('This effective date is before the effective date of existing pricing maps, are you sure you want to do this?')
  #   #   prompt2.accept
  #   # end
  # end  

end
