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
Capybara.ignore_hidden_elements = true

RSpec.describe 'as a user on catalog page', js: true do
  before :each do
    default_catalog_manager_setup
    wait_for_javascript_to_finish
  end

  it 'the user should create a pricing map' do

    core = Core.last
    click_link('MUSC Research Data Request (CDW)')
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Map")

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

      fill_in "pricing_maps_blank_pricing_map_full_rate", with: 4321
      fill_in "otf_quantity_type_", with: "hours"
      page.execute_script %Q{ $(".service_unit_factor").change() }
    end

    first(".save_button").click
    expect(page).to have_content "MUSC Research Data Request (CDW) saved successfully"
  end

  it 'should not save if required fields are missing' do
    click_link("MUSC Research Data Request (CDW)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Map")

    page.execute_script("$('.ui-accordion-header:last').click()")
    first(".save_button").click
    wait_for_javascript_to_finish
    expect(page).not_to have_content "MUSC Research Data Request (CDW) saved successfully"
  end

  it 'should display an error message when required fields are missing' do
    click_link("MUSC Research Data Request (CDW)")
    wait_for_javascript_to_finish
    first('#gen_info').click
    find('#service_one_time_fee').click
    wait_for_javascript_to_finish
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Map")
    wait_for_javascript_to_finish
    expect(page).to have_content "Name and Order are required on the Service.  Effective Date, Display Date, and Service Rate are required on all Pricing Maps."
    expect(page).to have_content "Clinical Quantity Type, Unit Factor, and Units Per Qty Maximum are required on all Per Patient Pricing Maps."
  end

  it "should remove the errors if the pricing map is removed" do
    click_link("MUSC Research Data Request (CDW)")
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    click_button("Add Pricing Map")
    click_link("Effective on - Display on")
    wait_for_javascript_to_finish
    click_button("Remove Pricing Map")
    expect(page).not_to have_content "Name and Order are required on the Service.  Effective Date, Display Date, and Service Rate are required on all Pricing Maps."
    expect(page).not_to have_content "Clinical Quantity Type, Unit Factor, and Units Per Qty Maximum are required on all Per Patient Pricing Maps."
  end

  describe 'one time fee checked' do

    before :each do
      click_link("MUSC Research Data Request (CDW)")
      wait_for_javascript_to_finish
      check 'service_one_time_fee'
      wait_for_javascript_to_finish
      within '#pricing' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
      click_button("Add Pricing Map")
      wait_for_javascript_to_finish
      click_link("Effective on - Display on")
      wait_for_javascript_to_finish
    end

    it "should open up the one time fee section correctly and display error message" do
      expect(page).to have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required."
    end

    it "should not allow save if one time fee fields are not filled in" do
      first(".save_button").click
      wait_for_javascript_to_finish
      expect(page).not_to have_content "MUSC Research Data Request (CDW) saved successfully"
    end

    it "should remove the error message if one time fee is unchecked" do
      expect(page).not_to have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Unit Type, and Unit Maximum are required."
    end

    it "should remove the error message if the fields are filled in" do
      find(".otf_quantity_type").set("Each")
      find(".otf_quantity_minimum").set(1)
      find(".otf_unit_type").set("Week")
      wait_for_javascript_to_finish

      expect(page).not_to have_content "If the Pricing Map is a one time fee (the box is checked), Quantity Type, Unit Type, and Unit Maximum are required."
    end

    it "should also not have any of the per patient errors on the page" do
      expect(page).not_to have_content "Name and Order on the Service, and Clinical Quantity Type, Unit Factor, Unit Minimum, Units Per Qty Maximum, Effective Date, and Display Date on all Pricing Maps are required."
    end
  end
end
