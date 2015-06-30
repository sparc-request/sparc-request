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
    (1..3).each do |index|
      service.service_level_components.push FactoryGirl.build(:service_level_component, position: index)
    end

    click_link service.name
  end

  def when_i_add_service_level_components_to_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    fill_in "service_service_level_components_attributes_3_component", with: "Test service component 3"
    fill_in "service_service_level_components_attributes_4_component", with: "Test service component 4"
    fill_in "service_service_level_components_attributes_5_component", with: "Test service component 5"
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def when_i_remove_service_level_components_from_the_service
    find(".service_level_components").click
    wait_for_javascript_to_finish
    check "service_service_level_components_attributes_0__destroy"
    check "service_service_level_components_attributes_1__destroy"
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def then_i_should_be_notified_that_the_service_was_successfully_updated
    page.should have_content "Human Subject Review saved successfully"
  end
end
