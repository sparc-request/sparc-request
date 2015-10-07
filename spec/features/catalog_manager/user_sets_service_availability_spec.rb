require 'rails_helper'

RSpec.feature 'User sets Service availability', js: true do

  scenario 'to unavailable' do
    given_i_am_viewing_catalog_manager
    when_i_set_the_service_availability_to_unavailable
    then_i_should_not_see_the_service
  end

  scenario 'to available' do
    given_i_am_viewing_catalog_manager
    when_i_set_the_service_availability_to_available
    then_i_should_see_the_service
  end

  def given_i_am_viewing_catalog_manager
    default_catalog_manager_setup
  end

  def when_i_set_the_service_availability_to_unavailable

  end

  def when_i_set_the_service_availability_to_available

  end

  def then_i_should_not_see_the_service

  end

  def then_i_should_see_the_service

  end
end
