require "spec_helper"

feature "create Service", js: true do

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
      fill_in "clinical_quantity_", with: "Each"
      find('#unit_factor_').click
    end
  end

  def then_i_should_be_notified_that_the_service_was_successfully_created
    page.should have_content "Test Service created successfully"
  end
end
