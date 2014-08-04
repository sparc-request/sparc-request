# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'

describe 'edit a pricing setup', :js => true do

  before :each do
    default_catalog_manager_setup
    click_link("Office of Biomedical Informatics")
    sleep 2
    page.execute_script("$('.ui-accordion-header').click()") 
  end
  
  it 'should successfully update a pricing_setup' do
        
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

  it "should update the date of a pricing map if updated on pricing setup" do
    
    within('.ui-accordion') do
      
      find('.display_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      page.execute_script("$('.fix_pricing_maps_button').click()")
      wait_for_javascript_to_finish
            
      find('.effective_date').click
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15    
      wait_for_javascript_to_finish
      
      page.execute_script("$('.fix_pricing_maps_button').click()")
      wait_for_javascript_to_finish      
    end
  
    page.execute_script %Q{ $(".save_button").click() }
    wait_for_javascript_to_finish
    
    page.should have_content "Office of Biomedical Informatics saved successfully"
    
    new_date = Date.parse(PricingSetup.last.display_date.to_s)
    pricing_map_date = Date.parse(PricingMap.last.display_date.to_s)
    
    new_date.should eq(pricing_map_date)
  end

  it "should not allow letters into the percentage fields" do

    within('.ui-accordion') do

      find('.corporate_percentage_field').set("Bob")
      find('.other_percentage_field').click
      page.should have_content "Corporate can only contain numbers."

      find('.other_percentage_field').set("Wilfred")
      find('.corporate_percentage_field').click
      page.should have_content "Other can only contain numbers."

      find('.member_percentage_field').set("Slappy")
      find('.other_percentage_field').click
      page.should have_content "Member can only contain numbers."
    end
  end

  it "should allow zeros into the percentage fields" do

    within('.ui-accordion') do

      find('.federal_percentage_field').set(0)
      find('.corporate_percentage_field').set(0)
      find('.other_percentage_field').set(0)
      find('.member_percentage_field').set(0)
    end

    find('.federal_percentage_field', :visible => true).should have_value('0')
    find('.corporate_percentage_field', :visible => true).should have_value('0')
    find('.other_percentage_field', :visible => true).should have_value('0')
    find('.member_percentage_field', :visible => true).should have_value('0')
  end
end