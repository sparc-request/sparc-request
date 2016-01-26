require 'rails_helper'

RSpec.feature 'User views Organizations', js: true do

  before(:each) do
    create_default_data
    @provider = Provider.first()
    @provider.update_attributes(is_available: false)
    login_as(Identity.find_by_ldap_uid('jug2@musc.edu'))
  end

  scenario 'and sees only available organizations' do
    given_i_am_viewing_catalog_manager
    then_i_should_only_see_available_organizations
  end

  scenario 'and views available and unavailable organizations' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_organizations
    then_i_should_see_all_organizations
  end

  def given_i_am_viewing_catalog_manager
    visit catalog_manager_root_path
    page.evaluate_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_only_see_available_organizations
    expect(page).to_not have_css("#PROVIDER#{@provider.id}")
  end

  def when_i_view_all_organizations
    save_and_open_page
    find('.unavailable_button').click
    page.evaluate_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_see_all_organizations
    expect(page).to have_content(@provider.name)
  end
end
