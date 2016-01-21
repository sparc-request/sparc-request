# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.feature 'user views Add Services link', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_study_type_questions
  build_study_type_question_groups
  build_service_request_with_project


  scenario "user views a protocol with service request status of 'first_draft'" do
    service_request.update_attributes(status: 'first_draft')
    when_i_visit_portal_path
    then_i_should_see_a_link_to_add_services
  end

  scenario "user views a protocol with a service_request of status 'draft'" do
    when_i_visit_portal_path
    then_i_should_not_see_a_link_to_add_services
  end

  scenario "user views a protocol without a service_request and visits 'Add Services'" do
    service_request.destroy
    when_i_visit_portal_path
    and_i_visit_add_services
    then_i_should_be_redierected_to_the_app_root_page
  end

  def and_i_visit_add_services
    find('.add-services-button').click
    wait_for_javascript_to_finish
  end

  def then_i_should_see_request_in_progress_text
    expect(page).to have_text('Request in Progress')
  end

  def then_i_should_be_redierected_to_the_app_root_page
    expect(page).to have_content("Welcome to the SPARC Request Services Catalog")
  end

  def when_i_visit_portal_path
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  def then_i_should_see_a_link_to_add_services
    expect(page).to have_selector('.add-services-button')
  end

  def then_i_should_not_see_a_link_to_add_services
    expect(page).to_not have_selector('.add-services-button')
  end

  def and_i_create_a_new_study_by_filling_out_study_info
    find('.portal_create_new_study').click
    fill_in "study_short_title", with: "Bob"
    fill_in "study_title", with: "Dole"
    fill_in "study_sponsor_name", with: "Captain Kurt 'Hotdog' Zanzibar"
    find('#study_has_cofc_true').click
    select "Funded", from: "study_funding_status"
    select "College Department", from: "study_funding_source"
    find('#study_selected_for_epic_false').click
    find('.continue_button').click
    wait_for_javascript_to_finish
  end

  def and_add_an_authorized_user
    select "Primary PI", from: "project_role_role"
    find('.add-authorized-user').click
    wait_for_javascript_to_finish
    find('.continue_button').click
    wait_for_javascript_to_finish
  end
end
