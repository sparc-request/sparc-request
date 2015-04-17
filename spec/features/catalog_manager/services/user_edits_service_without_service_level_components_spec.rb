require "spec_helper"

feature "User edits Service with no ServiceLevelCompnents present", js: true do

  scenario "and adds new ServiceLevelCompnents" do
    as_a_user_who_is_editing_a_service_which_has_no_service_level_components
    when_i_add_service_level_components_to_the_service
    then_i_should_be_notified_that_the_service_was_successfully_updated
  end

  scenario "and adds more ServiceLevelCompnents fields manually" do
    as_a_user_who_is_editing_a_service_which_has_no_service_level_components
    when_i_manually_add_service_level_components_to_the_service
    then_i_should_be_notified_that_the_service_was_successfully_updated
  end

  def as_a_user_who_is_editing_a_service_which_has_no_service_level_components
    default_catalog_manager_setup
    click_link "Human Subject Review"
  end

  def when_i_add_service_level_components_to_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    fill_in "service_service_level_components_attributes_0_component", with: "Test service component 1"
    fill_in "service_service_level_components_attributes_1_component", with: "Test service component 2"
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def when_i_manually_add_service_level_components_to_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    click_button "Add components"
    fill_in "service_service_level_components_attributes_3_component", with: "Test service component 3"
    fill_in "service_service_level_components_attributes_4_component", with: "Test service component 4"
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def then_i_should_be_notified_that_the_service_was_successfully_updated
    page.should have_content "Human Subject Review saved successfully"
  end
end
