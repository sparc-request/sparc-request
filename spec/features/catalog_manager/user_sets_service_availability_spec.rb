require 'rails_helper'

RSpec.feature 'User sets Service availability', js: true do

  before(:each) do
    create_default_data
    @service_available = Service.first()
    @service_unavailable = Service.last()
    @service_unavailable.update_attributes(is_available: false)
    login_as(Identity.find_by_ldap_uid('jug2@musc.edu'))
  end

  scenario 'to unavailable' do
    given_i_am_viewing_catalog_manager
    when_i_set_the_service_availability_to_unavailable
    then_i_should_not_see_the_service
  end

  scenario 'to available' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_services
    and_then_i_set_the_service_availability_to_available
    and_i_am_viewing_only_available_services
    then_i_should_see_the_service
  end

  def given_i_am_viewing_catalog_manager
    visit catalog_manager_root_path
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def when_i_set_the_service_availability_to_unavailable
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    find("#SERVICE#{@service_available.id} a").click
    find('#service_is_available').click
    first('#save_button').click
    wait_for_javascript_to_finish
  end

  def and_then_i_set_the_service_availability_to_available
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    find("#SERVICE#{@service_unavailable.id}").click
    find('#service_is_available').click
    first('#save_button').click
    wait_for_javascript_to_finish

  end

  def and_i_am_viewing_only_available_services
    find('.unavailable_button').click
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def when_i_view_all_services
    find('.unavailable_button').click
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_not_see_the_service
    expect(page).to_not have_css("#SERVICE#{@service_available.id}")
  end

  def then_i_should_see_the_service
    expect(page).to have_css("#SERVICE#{@service_unavailable.id}")
  end
end
