require "spec_helper"

feature "User edits Service with pre-existing ServiceLevelCompnents", js: true do

  scenario "and adds new ServiceLevelCompnents" do
    as_a_user_who_is_editing_a_service_which_has_service_level_components
    when_i_add_service_level_components_to_the_service
    then_i_should_be_notified_that_the_service_was_successfully_updated
  end

  scenario "and removes existing ServiceLevelCompnents" do
    as_a_user_who_is_editing_a_service_which_has_service_level_components
    when_i_remove_service_level_components_from_the_service
    then_i_should_be_notified_that_the_service_was_successfully_updated
  end

  def as_a_user_who_is_editing_a_service_which_has_service_level_components
    default_catalog_manager_setup
    service = Service.find_by_name('Human Subject Review')
    service.update_attributes(components: "a,b,c,")

    click_link service.name
  end

  def when_i_add_service_level_components_to_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    click_button "Add components"
    wait_for_javascript_to_finish
    find(".service_component_field[position='3']").set("Test service component 3")
    find(".service_component_field[position='4']").set("Test service component 4")
    find(".service_component_field[position='5']").set("Test service component 5")
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def when_i_remove_service_level_components_from_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    within("#service_component_position_0"){ click_button "Remove" }
    within("#service_component_position_1"){ click_button "Remove" }
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def then_i_should_be_notified_that_the_service_was_successfully_updated
    page.should have_content "Human Subject Review saved successfully"
  end
end
