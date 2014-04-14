require 'spec_helper'

feature 'automatic pricing adjustment' do
  background do
    default_catalog_manager_setup
  end
  
  scenario 'successfully creates pricing map with adjusted rates and dates', :js => true do

    wait_for_javascript_to_finish
    click_link('South Carolina Clinical and Translational Institute (SCTR)')

    sleep 3

    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    wait_for_javascript_to_finish
    click_button('Increase or Decrease Rates')
    wait_for_javascript_to_finish
    
    numerical_day = 10

    within('.increase_decrease_dialog') do
      page.execute_script %Q{ $(".percent_of_change").val("20") }
      wait_for_javascript_to_finish

      find('.change_rate_display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month      
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date

      # TODO: for some reason we are advancing the display date twice,
      # instead of opening the effective date dialog here.  This sleep
      # alleviates the problem.  How can we wait without sleeping?
      # (Note: wait_for_javascript_to_finish is not the answer; there
      # are no ajax calls involved here)
      sleep 5

      find('.change_rate_effective_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month      
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
    end
    
    within('.ui-dialog-buttonset') do
      click_button('Submit')
      wait_for_javascript_to_finish
    end

    page.should have_content('Successfully updated the pricing maps for all of the services under 
                              South Carolina Clinical and Translational Institute (SCTR).')
    
    ## Check to see if a pricing_map was actually created under the service with the correct dates.
    click_link('South Carolina Clinical and Translational Institute (SCTR)')
    wait_for_javascript_to_finish
    click_link('MUSC Research Data Request (CDW)')
    wait_for_javascript_to_finish
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    within('.pricing_map_accordion') do
      increase_decrease_date = (Date.today + 1.month).strftime("%-m/#{numerical_day}/%Y")
      page.should have_content("Effective on #{increase_decrease_date} - Display on #{increase_decrease_date}")
    end

  end

end
