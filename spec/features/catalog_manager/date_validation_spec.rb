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

feature 'effective and display date validations' do
  before :each do
    default_catalog_manager_setup
  end    
  
  scenario 'user cannot select the same effective date as an existing pricing_map', :js => true do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    sleep 1

    first('#pricing').click
    sleep 1

    first('.add_pricing_setup').click
    first('.pricing_setup_accordion h3').click
    sleep 1
 
    page.execute_script("$('.effective_date:visible').focus()")
    sleep 1
    first('.ui-datepicker-today').click #click on today's date
    sleep 1
 
    # This is the only way I could figure out how to test the text of the confirmation dialog
    get_alert_window do |prompt|
      # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail
      if prompt.text == ('A pricing map already exists with that effective date.  Please choose another date.')
        prompt.accept
      end
    end
  end
  
  scenario 'user cannot select the same display date as an existing pricing_map', :js => true do
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    sleep 1
    first('#pricing').click
    sleep 1

    first('.add_pricing_setup').click
    first('.pricing_setup_accordion h3').click
    sleep 1

    page.execute_script("$('.display_date:visible').focus()")
    sleep 1
    first('.ui-datepicker-today').click #click on today's date
    sleep 1

    # This is the only way I could figure out how to test the text of
    # the confirmation dialog
    get_alert_window do |prompt|
      # The test will pass if the confirmation dialog is closed, so if
      # text matches the test will pass, otherwise it will fail    
      if prompt.text == ('A pricing map already exists with that display date.  Please choose another date.')
        prompt.accept
      end
    end
  end
  

  scenario 'confirmation appears when a user selects an effective date that is before an existing effective date', :js => true do
    click_link("Office of Biomedical Informatics")
    sleep 1

    first('#pricing').click
    sleep 1

    first('.add_pricing_setup').click
    all('.pricing_setup_accordion h3').last.click
    sleep 1

    page.execute_script("$('.effective_date:visible').focus()")
    sleep 1
    page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # go back one month
    page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
    sleep 1

    # This is the only way I could figure out how to test the text of
    # the confirmation dialog
    prompt = retry_until {
      get_alert_window do |prompt|
        # The test will pass if the confirmation dialog is closed, so if
        # text matches the test will pass, otherwise it will fail    
        if prompt.text == ('This effective date is before the effective date of existing pricing maps, are you sure you want to do this?')
          prompt.dismiss # dismissed confirmation to avoid a second confirmation dialog, which capybara does not appear to handle
      end
    end
    }
    
  end
  
  scenario 'an alert will pop when a user selects an effective date in the increase/decrease rates dialog that is 
            the same as a pricing map', :js => true do

    click_link('South Carolina Clinical and Translational Institute (SCTR)')
    sleep 1

    first('#pricing').click
    sleep 1

    first('.increase_decrease_rates').click
    
    page.execute_script("$('.change_rate_display_date:visible').focus()")
    sleep 1
    first('a.ui-state-default.ui-state-highlight').click #click on today's date
    sleep 1

    # This is the only way I could figure out how to test the text of the confirmation dialog
    get_alert_window do |prompt|
      # The test will pass if the confirmation dialog is closed, so if text matches the test will pass, otherwise it will fail
      if prompt.text == ('A pricing map already exists with that display date.  Please choose another date.')
        prompt.accept
      end
    end
  end
end
