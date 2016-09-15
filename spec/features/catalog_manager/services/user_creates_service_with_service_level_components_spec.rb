# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.feature "create Service", js: true do

  scenario "with ServiceLevelRequest" do
    as_a_user_who_is_logged_into_catalog_manager
    when_i_create_a_service_with_service_level_requests
    then_i_should_be_notified_that_the_service_was_successfully_created
  end

  def as_a_user_who_is_logged_into_catalog_manager
    default_catalog_manager_setup
  end

  def when_i_create_a_service_with_service_level_requests
    program = Program.find_by_name "Office of Biomedical Informatics"

    within("#PROGRAM#{program.id} > ul > li:nth-of-type(2)") do
      click_link "Create New Service"
    end
    fill_in_service_form
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def fill_in_service_form
    fill_in_service_form_general
    fill_in_service_form_service_level_components
    fill_in_service_form_pricing_map
  end

  def fill_in_service_form_general
    fill_in "service_name", with: "Test Service"
    fill_in "service_abbreviation", with: "TestService"
    fill_in "service_order", with: 1
    fill_in "service_description", with: "Description"
  end

  def fill_in_service_form_service_level_components
    find('input#service_one_time_fee').click
    wait_for_javascript_to_finish
    find(".service_level_components").click
    wait_for_javascript_to_finish
    find(:css, ".service_component_field").set("Test service component 1")
  end

  def fill_in_service_form_pricing_map
    find('#pricing').click
    wait_for_javascript_to_finish
    click_button('Add Pricing Map')
    within('.ui-accordion') do
      page.execute_script %Q{ $('.ui-accordion-header:last').click() }
      page.execute_script %Q{ $('.pricing_map_display_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

      page.execute_script %Q{ $('.pricing_map_effective_date:visible').focus() }
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15

      fill_in "pricing_maps_blank_pricing_map_full_rate", with: 4321
      fill_in "otf_quantity_type_", with: "Each"
      find('#unit_factor_').click
    end
  end

  def then_i_should_be_notified_that_the_service_was_successfully_created
    expect(page).to have_content "Test Service created successfully"
  end
end
