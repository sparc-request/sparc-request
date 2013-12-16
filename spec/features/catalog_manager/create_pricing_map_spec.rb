require 'spec_helper'
Capybara.ignore_hidden_elements = true

describe 'as a user on catalog page', :js => true do
  before :each do
    default_catalog_manager_setup
  end

  it 'the user should create a pricing map' do
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
      fill_in "clinical_quantity_", :with => "Each"

      page.execute_script %Q{ $(".service_unit_factor").change() }
    end
    page.execute_script %Q{ $(".save_button").click() }
    page.should have_content "MUSC Research Data Request (CDW) saved successfully"    
  end
  
  it 'should not save if required fields are missing' do
    click_link("MUSC Research Data Request (CDW)")
    click_button("Add Pricing Map")
    
    page.execute_script("$('.ui-accordion-header:last').click()")
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    page.should_not have_content "MUSC Research Data Request (CDW) saved successfully"    
  end
  
  it 'should display an error message when required fields are missing' do
    click_link("MUSC Research Data Request (CDW)")
    click_button("Add Pricing Map")
    wait_for_javascript_to_finish
    page.should have_content "Name and Order on the Service, and Clinical Quantity Type, Unit Factor, Unit Minimum, Units Per Qty Maximum, Effective Date, and Display Date on all Pricing Maps are required."
  end

  it "should give the per patient fields a 'validate' class for a new map with one time fees unchecked" do
    click_link("MUSC Research Data Request (CDW)")
    click_button("Add Pricing Map")
    click_link("Effective on - Display on")
    wait_for_javascript_to_finish

    find(".service_unit_type.validate").click #will fail if it doesn't have the validate class
  end

  describe 'one time fee checked' do

    before :each do
      click_link("MUSC Research Data Request (CDW)")
      click_button("Add Pricing Map")
      click_link("Effective on - Display on")
      find("#otf_checkbox_").click
      wait_for_javascript_to_finish
    end

    it "should open up the one time fee section correctly and display error message" do
      page.should have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required."
    end

    it "should not allow save if one time fee fields are not filled in" do
      page.execute_script %Q{ $(".save_button").click() }
      wait_for_javascript_to_finish
      page.should_not have_content "MUSC Research Data Request (CDW) saved successfully"  
    end

    it "should remove the error message if one time fee is unchecked" do
      find("#otf_checkbox_").click
      page.should_not have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Unit Type, and Unit Maximum are required."
    end

    it "should remove the error message if the fields are filled in" do
      find(".otf_quantity_type").set("Each")
      find(".otf_quantity_minimum").set(1)
      find(".otf_unit_type").set("Week")
      wait_for_javascript_to_finish

      page.should_not have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Unit Type, and Unit Maximum are required."
    end

    it "should also not have any of the per patient errors on the page" do
      page.should_not have_content "Name and Order on the Service, and Clinical Quantity Type, Unit Factor, Unit Minimum, Units Per Qty Maximum, Effective Date, and Display Date on all Pricing Maps are required."
    end

  end    

end
