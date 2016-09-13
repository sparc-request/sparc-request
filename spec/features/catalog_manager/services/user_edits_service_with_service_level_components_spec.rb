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

RSpec.feature "User edits Service with pre-existing ServiceLevelCompnents", js: true do

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
    expect(page).to have_content "Human Subject Review saved successfully"
  end
end
