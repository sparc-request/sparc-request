require 'rails_helper'

RSpec.feature 'User views Services', js: true do

  scenario 'and sees only available Services' do
    given_i_am_viewing_catalog_manager
    then_i_should_only_see_available_services
  end

  scenario 'and views available and unavailable Services' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_services
    then_i_should_see_all_services
  end

  def given_i_am_viewing_catalog_manager
    default_catalog_manager_setup
  end

  def then_i_should_only_see_available_services
    save_and_open_screenshot
  end

  def when_i_view_all_services

  end

  def then_i_should_see_all_services

  end
end
