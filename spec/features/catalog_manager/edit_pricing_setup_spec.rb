require 'spec_helper'

feature 'edit a pricing setup' do
  background do
    default_catalog_manager_setup
  end
  
  scenario 'a user can successfully update a pricing_setup', :js => true do
    click_link("Office of Biomedical Informatics")
    sleep 2
    
    page.execute_script("$('.ui-accordion-header').click()") 
    
    within('.ui-accordion') do
      
      find('.display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      page.execute_script("$('.dont_fix_pricing_maps_button').click()")
            
      find('.effective_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      page.execute_script("$('.dont_fix_pricing_maps_button').click()")
      
      find('.federal_percentage_field').set('250')
      click_link('Apply Federal % to All')
      page.execute_script %Q{ $(".rate").val("full") }
      page.execute_script %Q{ $(".rate").change() }
    end
  
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    page.should have_content "Office of Biomedical Informatics saved successfully"
    
  end
  
  ## Need to create a test that will confirm that a dialog pops when changing a date of a pricing_setup that has a related pricing_map.
  ## Need to confirm that changing the pricing_map date to match the pricing_setup works.

end