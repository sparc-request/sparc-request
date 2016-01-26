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

RSpec.feature 'User wants to add an authorized user', js: true do
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

  context 'and clicks the Add an Authorized User button' do
    scenario 'and sees the Add Authorized User dialog' do
      given_i_have_clicked_the_add_authorized_user_button
      then_i_should_see_the_add_authorized_user_dialog
    end

    context 'and searches for a user not already on the protocol' do
      scenario 'and sees the users information' do
        given_i_have_clicked_the_add_authorized_user_button
        when_i_select_a_user_from_the_search
        then_i_should_see_the_users_basic_information
      end
      
      context 'and sets the users rights to Primary PI, PD/PI, or Billing/Business Manager' do
        scenario 'and sees the highest user rights selected' do
          given_i_have_clicked_the_add_authorized_user_button
          when_i_select_a_user_from_the_search
          when_i_set_the_role_to 'Primary PI'
          then_i_should_see_the_highest_level_of_rights_selected
          when_i_set_the_role_to 'PD/PI'
          then_i_should_see_the_highest_level_of_rights_selected
          when_i_set_the_role_to 'Billing/Business Manager'
          then_i_should_see_the_highest_level_of_rights_selected
        end
      end

      context 'and fills out the required fields' do
        context 'and submits the form' do
          scenario 'and sees the User has been added to the protocol' do
            given_i_have_clicked_the_add_authorized_user_button
            when_i_select_a_user_from_the_search
            when_i_fill_out_the_required_fields
            when_i_submit_the_form
            then_i_should_see_the_user_has_been_added
          end
        end

        context 'but sets role and credentials to other' do
          context 'and fills out the extra fields' do
            scenario 'and sees they can submit the form' do
              given_i_have_clicked_the_add_authorized_user_button
              when_i_select_a_user_from_the_search
              when_i_set_the_role_and_credentials_to_other
              when_i_fill_out_the_other_fields
              when_i_submit_the_form
              then_i_should_not_see_an_error_of_type 'other fields'
            end
          end

          context 'and leaves the extra fields blank' do
            scenario 'and sees some errors' do
              given_i_have_clicked_the_add_authorized_user_button
              when_i_select_a_user_from_the_search
              when_i_fill_out_the_required_fields
              when_i_set_the_role_and_credentials_to_other
              when_i_submit_the_form
              then_i_should_see_an_error_of_type 'other fields'
            end
          end
        end
      end

      context 'and does not fill out the required fields and submits the form' do
        scenario 'and sees some errors' do
          given_i_have_clicked_the_add_authorized_user_button
          when_i_select_a_user_from_the_search
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'fields missing'
        end
      end

      context 'and sets their role to Primary PI' do
        context 'and submits the form' do
          scenario 'and sees the warning message' do
            given_i_have_clicked_the_add_authorized_user_button
            when_i_select_a_user_from_the_search
            when_i_set_the_role_to 'Primary PI'
            when_i_submit_the_form
            then_i_should_see_the_warning_message
          end

          context 'and submits the form on the warning message' do
            scenario 'and sees the Primary PI has changed' do
              given_i_have_clicked_the_add_authorized_user_button
              when_i_select_a_user_from_the_search
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_new_primary_pi
            end

            scenario 'and sees the old primary pi is a general access user' do
              given_i_have_clicked_the_add_authorized_user_button
              when_i_select_a_user_from_the_search
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_old_primary_pi_is_a_general_user
            end

            scenario 'and sees the old primary pi has request rights' do
              given_i_have_clicked_the_add_authorized_user_button
              when_i_select_a_user_from_the_search
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_old_primary_pi_has_request_rights
            end

            context 'with errors in the form' do
              scenario 'and sees errors' do
                given_i_have_clicked_the_add_authorized_user_button
                when_i_select_a_user_from_the_search
                when_i_set_the_role_to 'Primary PI'
                when_i_have_an_error
                when_i_submit_the_form
                when_i_submit_the_form
                then_i_should_see_an_error_of_type 'other credentials'
              end
            end
          end
        end
      end
    end

    context 'and searches for a user already on the protocol and tries to add the user' do
      scenario 'and sees a duplicate identity error on the protocol' do
        #Create Brian
        given_i_have_clicked_the_add_authorized_user_button
        when_i_select_a_user_from_the_search
        when_i_fill_out_the_required_fields
        when_i_submit_the_form
        #Try to create Brian again
        given_i_have_clicked_the_add_authorized_user_button
        when_i_select_a_user_from_the_search
        when_i_fill_out_the_required_fields
        when_i_submit_the_form
        then_i_should_see_an_error_of_type 'user already added'
      end
    end
  end

  def given_i_have_clicked_the_add_authorized_user_button
    find(".associated-user-button", visible: true).click()
  end

  def when_i_select_a_user_from_the_search
    fill_autocomplete('user_search', with: 'bjk7')
    page.find('a', text: "Brian Kelsey", visible: true).click()
  end

  def when_i_set_the_role_to role
    select role, from: 'project_role_role'
  end
  
  def when_i_set_the_credentials_to credentials
    select credentials, from: 'identity_credentials'
  end

  def when_i_fill_out_the_required_fields
    select "Co-Investigator", from: 'project_role_role'
    choose 'project_role_project_rights_request'
  end

  def when_i_set_the_role_and_credentials_to_other
    when_i_set_the_role_to 'Other'
    when_i_set_the_credentials_to 'Other'
  end

  def when_i_fill_out_the_other_fields
    fill_in 'project_role_role_other', with: 'asdf'
    fill_in 'identity_credentials_other', with: 'asdf'
  end

  def when_i_submit_the_form
    click_button("add_authorized_user_submit_button")
  end

  def when_i_have_an_error
    when_i_set_the_credentials_to 'Other'
  end

  def then_i_should_see_the_add_authorized_user_dialog
    expect(page).to have_text 'Add User'
  end

  def then_i_should_see_the_users_basic_information
    expect(page).to have_css('#full_name')
    expect(find('#full_name')).to have_value 'Brian Kelsey'
  end

  def then_i_should_see_the_highest_level_of_rights_selected
    expect(find("#project_role_project_rights_approve")).to be_checked()
  end

  def then_i_should_see_the_user_has_been_added
    within('.admin#users') do
      expect(page).to have_text('Brian Kelsey')
      expect(page).to have_text('Co-Investigator')
      expect(page).to have_text('Request/Approve Services')
    end
  end

  def then_i_should_see_the_warning_message
    expect(page).to have_text("**WARNING**")
  end

  def then_i_should_see_the_new_primary_pi
    wait_for_javascript_to_finish
    brian_id = Identity.find_by_ldap_uid("bjk7@musc.edu")

    expect(page).to have_selector("#users td", text: "Brian Kelsey")
    expect(page).to have_selector('#users td', text: "Primary PI")    

    expect(page).to have_selector('#information td', text: "Brian Kelsey")

    expect(Protocol.first.primary_principal_investigator).to eq(brian_id)
  end

  def then_i_should_see_the_old_primary_pi_is_a_general_user
    wait_for_javascript_to_finish
    expect(ProjectRole.where(identity_id: Identity.find_by_ldap_uid("jug2"), protocol_id: Protocol.first.id).first.role).to eq("general-access-user")
  end

  def then_i_should_see_the_old_primary_pi_has_request_rights
    wait_for_javascript_to_finish
    expect(ProjectRole.find_by(identity_id: Identity.find_by_ldap_uid("jug2"), protocol_id: Protocol.first.id).project_rights).to eq("request")
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'other fields'
        expect(page).to have_text("Must specify this User's Role.")
        expect(page).to have_text("Must specify this User's Credentials.")
      when 'other credentials'
        expect(page).to have_text("Must specify this User's Credentials.")
      when 'fields missing'
        expect(page).to have_text("Role can't be blank")
        expect(page).to have_text("Project_rights can't be blank")
      when 'user already added'
        expect(page).to have_text("This user is already associated with this protocol.")
      when 'only 1 Primary PI'
        expect(page).to have_text("This protocol already has a Primary PI.")
      else
        puts "An unexpected error was found in then_i_should_see_an_error_of_type. Perhaps there was a typo in the test?"
        expect(0).to eq(1)
    end
  end

  def then_i_should_not_see_an_error_of_type error_type
    case error_type
      when 'other fields'
        expect(page).to_not have_text("Must specify this User's Role.")
        expect(page).to_not have_text("Must specify this User's Credentials.")
      else
        puts "An unexpected error was found in then_i_should_not_see_an_error_of_type. Perhaps there was a typo in the test?"
        expect(0).to eq(1)
    end
  end
end
