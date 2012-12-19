require 'spec_helper'

describe 'as a user on catalog page' do
  it 'the user should create a pricing map', :js => true do
    default_catalog_manager_setup
    
    core = Core.last
    click_link('MUSC Research Data Request (CDW)')

    click_button("Add Pricing Map")

    # page.execute_script("$('.ui-accordion-header').click()") 
    within('.ui-accordion') do
      page.execute_script %Q{ $('.ui-accordion-header:last').click() }
      page.execute_script %Q{ $('.pricing_map_display_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      page.execute_script %Q{ $('.pricing_map_effective_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      fill_in "pricing_maps_blank_pricing_map_full_rate", :with => 4321
      fill_in "pricing_maps_blank_pricing_map_unit_type", :with => "Each"
      
      page.execute_script %Q{ $(".service_unit_type").change() }
    end
    page.execute_script %Q{ $(".save_button").click() }
    page.should have_content "MUSC Research Data Request (CDW) saved successfully"    
  end

end
