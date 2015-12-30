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

RSpec.feature 'User wants to edit an authorized user', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project
  
  before :each do
    add_visits
    
    visit portal_admin_sub_service_request_path sub_service_request.id
    wait_for_javascript_to_finish
    page.find('a', text: "Authorized Users", visible: true).click()
  end

  context 'and clicks the Edit Authorized User button' do
    scenario 'and sees the Edit Authorized User dialog' do
      given_i_have_clicked_the_edit_authorized_user_button
      then_i_should_see_the_edit_authorized_user_dialog
    end

    scenario 'and sees the users information' do
      given_i_have_clicked_the_edit_authorized_user_button
      then_i_should_see_the_user_information
    end

    context 'and the Authorized User is the Primary PI' do
      context 'and wants to change the Authorized Users role' do
        scenario 'and sees that the protocol must have a Primary PI' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_role_to 'PD/PI'
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'need Primary PI'
        end
      end
    end

    context 'and sets the role and credentials to other, makes the extra fields empty, and submits the form' do
      scenario 'and sees some errors' do
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_role_and_credentials_to_other
        when_i_submit_the_form
        then_i_should_see_an_error_of_type 'other fields'
      end
    end
  end

  def given_i_have_clicked_the_edit_authorized_user_button
    first(".edit-associated-user-button", visible: true).click()
  end

  def when_i_set_the_role_to role
    select role, from: 'project_role_role'
  end

  def when_i_set_the_credentials_to credentials
    select credentials, from: 'identity_credentials'
  end

  def when_i_set_the_role_and_credentials_to_other
    when_i_set_the_role_to 'Other'
    when_i_set_the_credentials_to 'Other'
  end

  def when_i_submit_the_form
    click_button("edit_authorized_user_submit_button")
  end

  def then_i_should_see_the_edit_authorized_user_dialog
    expect(page).to have_text("Edit an Authorized User")
  end

  def then_i_should_see_the_user_information
    lane = Identity.find_by_ldap_uid("jug2")
    lane_pr = ProjectRole.find_by_identity_id(lane.id)
    expect(find('#full_name', visible: true)).to have_value("#{lane.first_name} #{lane.last_name}")
    expect(find('#email', visible: true)).to have_value(lane.email)
    expect(find('#identity_phone', visible: true)).to have_value(lane.phone)
    expect(find('#project_role_role', visible: true)).to have_value(lane_pr.role)
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'need Primary PI'
        expect(page).to have_text("Must include one Primary PI.")
      when 'role blank'
        expect(page).to have_text("Role can't be blank")
      when 'other fields'
        expect(page).to have_text("Must specify this User's Role.")
        expect(page).to have_text("Must specify this User's Credentials.")
    else
      puts "An unexpected error was found in then_i_should_see_an_error_of_type. Perhaps there was a typo in the test?"
      expect(0).to eq(1)
    end
  end
end
