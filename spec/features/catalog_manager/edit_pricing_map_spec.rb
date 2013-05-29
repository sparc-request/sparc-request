require 'spec_helper'

describe 'as a user on catalog page', :js => true do
  before(:each) do
    default_catalog_manager_setup
    
    # The pricing setup date must be on or before the date of the
    # pricing map we want to create.  The test below seems to be
    # creating a pricing map with date 2000-04-15.  The pricing setup
    # that's created by create_default_data() has a date of today.  This
    # should create a pricing setup that will work for this test.
    pricing_setup = FactoryGirl.create(
        :pricing_setup,
        organization_id:   Program.first.id,
        display_date:      '2000-01-01',
        effective_date:    '2000-01-01')

    click_link('MUSC Research Data Request (CDW)')
    sleep 2
    
    page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()")
  end

  it 'should successfully update an existing pricing map' do
    
    within('.ui-accordion > div:nth-of-type(2)') do
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

      ## using find('selector').set('value') was the only thing I could get to work with these fields.
      find("input[id$='full_rate']").set(3800) ## change the service rate
      find("input[id$='unit_type']").set("Each") ## change the quantity type
      find("input[id$='unit_minimum']").set(2) ## change the unit minimum
      find("input[id$='units_per_qty_max']").set(2) ## change the units per qty max
      page.execute_script %Q{ $("input[id$='units_per_qty_max']").change() }

    end

    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    page.should have_content "MUSC Research Data Request (CDW) saved successfully"        
  end

  it "should save the fields after the return key is hit" do

    within('.ui-accordion > div:nth-of-type(2)') do

      find("input[id$='full_rate']").set(2000) 
      find("input[id$='full_rate']").native.send_keys(:return)
      wait_for_javascript_to_finish
      find("input[id$='full_rate']").should have_value("2,000.00")
    end
  end

  describe 'one time fee' do

    before :each do
      page.execute_script("$('.ui-accordion > div:nth-of-type(2)').click()")
    end

    it "should set the one time fee attribute to true when clicked" do
      service = Service.find_by_abbreviation("CDW")
      find(".pricing_map_accordion > h3:nth-of-type(1)").click
      find("td.is_one_time_fee > input", :visible => true).click
      page.execute_script %Q{ $(".save_button").click() }
      wait_for_javascript_to_finish

      service.pricing_maps[1].is_one_time_fee.should eq(false)
    end
  end
end
