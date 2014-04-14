require 'spec_helper'
Capybara.ignore_hidden_elements = true

describe 'as a user on catalog page', :js => true do
  before(:each) do
    default_catalog_manager_setup
  end
  
  it 'the user should create a pricing setup' do
    provider = Organization.where(abbreviation: 'SCTR1').first
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Setup")
    wait_for_javascript_to_finish
    
    page.execute_script("$('.ui-accordion-header').click()") 
    within('.ui-accordion') do
      find('.display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      find('.effective_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      find('.federal_percentage_field').set('150')
      click_link('Apply Federal % to All')
      wait_for_javascript_to_finish
      page.execute_script %Q{ $(".rate").val("full") }
      page.execute_script %Q{ $(".rate").change() }
      wait_for_javascript_to_finish
    end
  
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    provider.pricing_setups.first.federal.should eq(150)
    
  end
  
  it 'should not save if required fields are missing' do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Setup")
    
    page.execute_script("$('.ui-accordion-header').click()")
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    page.should_not have_content "South Carolina Clinical and Translational Institute (SCTR) saved successfully"    
  end
  
  it 'should display an error message when required fields are missing' do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Setup")
    
    page.execute_script("$('.ui-accordion-header').click()")
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    page.should have_content "Effective Date, Display Dates, Percent of Fee, and Rates are required on all pricing setups."        
  end
  
  it 'should display an error when rates are less than the federal rate in the percent of fee section' do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Setup")
    
    page.execute_script("$('.ui-accordion-header').click()")

    within('.ui-accordion') do
      find('.federal_percentage_field').set('50')
    
      find('.corporate_percentage_field').set('49')
      page.execute_script %Q{ $(".corporate_percentage_field").change() }
      page.should have_content "Corporate percentage must be >= to the Federal percentage."
    
      find('.other_percentage_field').set('49')
      page.execute_script %Q{ $(".other_percentage_field").change() }
      page.should have_content "Other percentage must be >= to the Federal percentage."

      find('.member_percentage_field').set('49')
      page.execute_script %Q{ $(".member_percentage_field").change() }
      page.should have_content "Member percentage must be >= to the Federal percentage."
    end
  end
  
  it 'should create a pricing map with the same dates as the pricing setup' do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Setup")
    
    page.execute_script("$('.ui-accordion-header').click()") 
    within('.ui-accordion') do
      find('.display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish

      find('.effective_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      find('.federal_percentage_field').set('150')
      click_link('Apply Federal % to All')
      page.execute_script %Q{ $(".rate").val("full") }
      page.execute_script %Q{ $(".rate").change() }
    end
  
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish

    page.should have_content "South Carolina Clinical and Translational Institute (SCTR) saved successfully"

    ## Check to verify pricing map was created.
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    click_link("MUSC Research Data Request (CDW)")
    wait_for_javascript_to_finish
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    
    increase_decrease_date = (Date.today + 2.month).strftime("%-m/15/%Y")
    page.should have_content("Effective on #{increase_decrease_date} - Display on #{increase_decrease_date}")

    ## Ensure pricing map copied over the content from the existing pricing map
    page.execute_script("$('.ui-accordion-header:last').click()")
    wait_for_javascript_to_finish
    find('.otf_checkbox').click
    wait_for_javascript_to_finish
    # Check the last pricing map.
    find('.service_rate').should have_value '45.00'
    find('.service_unit_type').should have_value 'self'
  end
end
