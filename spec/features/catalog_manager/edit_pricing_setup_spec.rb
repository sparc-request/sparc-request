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

RSpec.describe 'edit a pricing setup', js: true do

  before :each do
    default_catalog_manager_setup
    click_link("Office of Biomedical Informatics")
    wait_for_javascript_to_finish
    page.execute_script("$('.ui-accordion-header').click()")
  end

  ## Need to create a test that will confirm that a dialog pops when changing a date of a pricing_setup that has a related pricing_map.
  ## Need to confirm that changing the pricing_map date to match the pricing_setup works.

  it "should update the date of a pricing map if updated on pricing setup" do

    within('.ui-accordion') do

      enter_display_date

      page.execute_script("$('.fix_pricing_maps_button').click()")
      wait_for_javascript_to_finish

      enter_effective_date

      page.execute_script("$('.fix_pricing_maps_button').click()")
      wait_for_javascript_to_finish
    end
    first(".save_button").click
    wait_for_javascript_to_finish
    expect(page).to have_content "Office of Biomedical Informatics saved successfully"

    new_date = Date.parse(PricingSetup.last.display_date.to_s)
    pricing_map_date = Date.parse(PricingMap.last.display_date.to_s)

    expect(new_date).to eq(pricing_map_date)
  end

  it "should allow zeros into the percentage fields" do

    within('.ui-accordion') do

      find('.federal_percentage_field').set(0)
      find('.corporate_percentage_field').set(0)
      find('.other_percentage_field').set(0)
      find('.member_percentage_field').set(0)
    end

    expect(find('.federal_percentage_field', visible: true)).to have_value('0')
    expect(find('.corporate_percentage_field', visible: true)).to have_value('0')
    expect(find('.other_percentage_field', visible: true)).to have_value('0')
    expect(find('.member_percentage_field', visible: true)).to have_value('0')
  end
end

def enter_display_date
  page.execute_script("$('.display_date:visible').focus()")

  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move three months forward
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") }
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") }
  page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

  # close datepicker, which may overlap other elements on the page
  page.execute_script %Q{ $('.display_date').datepicker('destroy') }
  page.execute_script %Q{ $('.displat_date').hide() }
  wait_for_javascript_to_finish
end

def enter_effective_date
  page.execute_script("$('.effective_date:visible').focus()")

  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move three months forward
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") }
  page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") }
  page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

  # close datepicker, which may overlap other elements on the page
  page.execute_script %Q{ $('.effective_date').datepicker('destroy') }
  page.execute_script %Q{ $('.effective_date').hide() }
  wait_for_javascript_to_finish
end
