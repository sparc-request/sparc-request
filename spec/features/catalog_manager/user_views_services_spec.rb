require 'rails_helper'

RSpec.feature 'User views Services', js: true do

  before(:each) do
    create_default_data
    @service_unavailable = Service.first()
    @service_unavailable.update_attributes(is_available: false)
    @service_available = Service.last()
    login_as(Identity.find_by_ldap_uid('jug2@musc.edu'))
  end

  scenario 'and sees only available Services' do
    given_i_am_viewing_catalog_manager
    then_i_should_only_see_available_services
  end

  scenario 'and sees all Services' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_services
    then_i_should_see_all_services
  end

  def given_i_am_viewing_catalog_manager
    visit catalog_manager_root_path
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_only_see_available_services
    expect(page).to have_css("#SERVICE#{@service_available.id}")
    expect(page).to_not have_css ("#SERVICE#{@service_unavailable.id}")
  end

  def when_i_view_all_services
    find('.unavailable_button').click
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_see_all_services
    expect(page).to have_css("#SERVICE#{@service_available.id}")
    expect(page).to have_css("#SERVICE#{@service_unavailable.id}.entity_visibility")
  end
end
