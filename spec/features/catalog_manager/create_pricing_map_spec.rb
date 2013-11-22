require 'spec_helper'

describe 'as a user on catalog page' do
  before :each do
    default_catalog_manager_setup
  end

  it 'the user should create a pricing map', :js => true do
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
      fill_in "pricing_maps_blank_pricing_map_units_per_qty_max", :with => "1"
      
      page.execute_script %Q{ $(".service_units_per_qty_max").change() }
    end
    page.execute_script %Q{ $(".save_button").click() }
    page.should have_content "MUSC Research Data Request (CDW) saved successfully"    
  end
  
  it 'should not save if required fields are missing', :js => true do
    click_link("MUSC Research Data Request (CDW)")
    click_button("Add Pricing Map")
    
    page.execute_script("$('.ui-accordion-header:last').click()")
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    page.should_not have_content "MUSC Research Data Request (CDW) saved successfully"    
  end
  
  it 'should display an error message when required fields are missing', :js => true do
    click_link("MUSC Research Data Request (CDW)")
    click_button("Add Pricing Map")
    wait_for_javascript_to_finish
    page.should have_content "Name and Order on the Service, and Clinical Quantity Type, Unit Factor, Unit Minimum, Units Per Qty Maximum, Effective Date, and Display Date on all Pricing Maps are required."
  end    

end
