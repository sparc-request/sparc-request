# Copyright © 2011-2016 MUSC Foundation for Research Development
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

require 'rails_helper'

RSpec.feature 'effective and display date validations', js: true do

  scenario 'user cannot select the same effective date as an existing pricing_map' do
    default_catalog_manager_setup
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    wait_for_javascript_to_finish
    first('#pricing').click
    wait_for_javascript_to_finish
    first('.add_pricing_setup').click
    wait_for_javascript_to_finish
    first('.pricing_setup_accordion h3').click
    wait_for_javascript_to_finish
    page.execute_script("$('.effective_date:visible').focus()")
    wait_for_javascript_to_finish
    message = accept_alert do
      first('.ui-datepicker-today').click
    end
    wait_for_javascript_to_finish

    expect(message).to eq('A pricing map already exists with that effective date.  Please choose another date.')
  end

  scenario 'user cannot select the same display date as an existing pricing_map' do
    default_catalog_manager_setup
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    wait_for_javascript_to_finish
    first('#pricing').click
    wait_for_javascript_to_finish
    first('.add_pricing_setup').click
    wait_for_javascript_to_finish
    first('.pricing_setup_accordion h3').click
    wait_for_javascript_to_finish
    page.execute_script("$('.display_date:visible').focus()")
    wait_for_javascript_to_finish
    message = accept_alert do
      find('.ui-datepicker-today').click
    end
    wait_for_javascript_to_finish

    expect(message).to eq('A pricing map already exists with that display date.  Please choose another date.')
  end

  scenario 'confirmation appears when a user selects an effective date that is before an existing effective date' do
    default_catalog_manager_setup
    click_link("Office of Biomedical Informatics")
    wait_for_javascript_to_finish
    first('#pricing').click
    wait_for_javascript_to_finish
    first('.add_pricing_setup').click
    all('.pricing_setup_accordion h3').last.click
    wait_for_javascript_to_finish
    page.execute_script("$('.effective_date:visible').focus()")
    wait_for_javascript_to_finish
    page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") }
    wait_for_javascript_to_finish
    message = dismiss_confirm do
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
    end
    wait_for_javascript_to_finish

    expect(message).to eq('This effective date is before the effective date of existing pricing maps, are you sure you want to do this?')
  end

  scenario 'an alert will pop when a user selects an effective date in the increase/decrease rates dialog that is the same as a pricing map' do
    default_catalog_manager_setup
    click_link('South Carolina Clinical and Translational Institute (SCTR)')
    wait_for_javascript_to_finish
    first('#pricing').click
    wait_for_javascript_to_finish
    first('.increase_decrease_rates').click
    page.execute_script("$('.change_rate_display_date:visible').focus()")
    wait_for_javascript_to_finish
    message = accept_alert do
      first('a.ui-state-default.ui-state-highlight').click #click on today's date
    end
    wait_for_javascript_to_finish

    expect(message).to eq('A pricing map already exists with that display date.  Please choose another date.')
  end
end
