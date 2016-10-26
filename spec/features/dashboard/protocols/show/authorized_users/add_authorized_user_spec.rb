# Copyright © 2011-2016 MUSC Foundation for Research Development
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
  let!(:logged_in_user) { create(:identity, last_name: "Doe", first_name: "John", ldap_uid: "johnd", email: "johnd@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  let!(:other_user) { create(:identity, last_name: "Doe", first_name: "Jane", ldap_uid: "janed", email: "janed@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  before(:each) { stub_const('USE_LDAP', false) }

  context 'which is not assigned to themself' do
    let!(:protocol) { create(:unarchived_project_without_validations, primary_pi: logged_in_user) }

    context 'and has permission to edit the protocol' do
      fake_login_for_each_test("johnd")

      before :each do
        # navigate to page
        @page = Dashboard::Protocols::ShowPage.new
        @page.load(id: protocol.id)
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

            context 'but sets role and credentials to other and fills out the extra fields' do
              scenario 'and sees they can submit the form' do
                given_i_have_clicked_the_add_authorized_user_button
                when_i_select_a_user_from_the_search
                when_i_set_the_role_and_credentials_to_other
                when_i_fill_out_the_other_fields
                when_i_submit_the_form
                then_i_should_not_see_an_error_of_type 'other fields'
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
            # add user
            given_i_have_clicked_the_add_authorized_user_button
            when_i_select_a_user_from_the_search
            when_i_fill_out_the_required_fields
            when_i_submit_the_form

            # try to add same user again
            given_i_have_clicked_the_add_authorized_user_button
            when_i_select_a_user_from_the_search
            then_i_should_see_an_error_of_type 'user already added'
          end
        end
      end
    end

    context 'and does not have permission to edit the protocol' do
      fake_login_for_each_test("janed")

      scenario 'and sees the disabled Add an Authorized User button' do
        create(:project_role,
               identity: other_user,
               protocol: protocol,
               project_rights: 'view',
               role: 'mentor')

        page = Dashboard::Protocols::ShowPage.new
        page.load(id: protocol.id)
        expect(page).to have_disabled_add_authorized_user_button
        expect(page).to have_no_enabled_add_authorized_user_button
      end
    end
  end

  context 'which is assigned to themself (thus assuming they are an Admin)' do
    fake_login_for_each_test("johnd")

    context 'and sets the rights to approve or request' do
      before :each do
        protocol        = create(:unarchived_project_without_validations, primary_pi: other_user)
        organization    = create(:organization)
        organization2   = create(:organization)
        service_request = create(:service_request_without_validations, protocol: protocol)
                          create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                          create(:sub_service_request_without_validations, service_request: service_request, organization: organization2, status: 'draft')
                          create(:super_user, organization: organization, identity: logged_in_user)
        # navigate to page
        @page = Dashboard::Protocols::ShowPage.new
        @page.load(id: protocol.id)
        
        given_i_have_clicked_the_add_authorized_user_button
        when_i_select_a_user_from_the_search('John Doe')
        when_i_set_the_role_to('Consultant')
        @page.authorized_user_modal.approve_rights.click
        when_i_submit_the_form
        wait_for_javascript_to_finish
      end

      scenario 'and sees the edit button for all non-locked SSRs' do
        expect(@page.service_requests.first.ssrs.first).to have_edit_button
        expect(@page.service_requests.first.ssrs.second).to have_edit_button
      end

      scenario 'and sees the Modify Request button for all SRs' do
        expect(@page).to have_selector('.panel-heading .edit-service-request')
      end
    end
  end

  def given_i_have_clicked_the_add_authorized_user_button
    @page.enabled_add_authorized_user_button.click
  end

  def when_i_select_a_user_from_the_search(user='Jane Doe')
    @page.authorized_user_modal.instance_exec do
      select_user_field.set(user)
      wait_for_user_choices
      user_choices(text: user).first.click
      # wait for a field to appear to indicate that user search completed
      wait_for_credentials_dropdown
    end
  end

  def when_i_set_the_role_to(role)
    @page.authorized_user_modal.instance_exec do
      role_dropdown.click
      wait_for_dropdown_choices
      dropdown_choices(text: /\A#{role}\Z/).first.click
      wait_until_dropdown_choices_invisible
    end
  end

  def when_i_set_the_credentials_to(credentials)
    @page.authorized_user_modal.instance_exec do
      credentials_dropdown.click
      wait_for_dropdown_choices
      dropdown_choices(text: /\A#{credentials}\Z/).first.click
      wait_until_dropdown_choices_invisible
    end
  end

  def when_i_fill_out_the_required_fields
    when_i_set_the_role_to('Co-Investigator')
    @page.authorized_user_modal.request_rights.click
  end

  def when_i_set_the_role_and_credentials_to_other
    when_i_set_the_role_to('Other')
    @page.authorized_user_modal.wait_until_specify_other_role_visible
    when_i_set_the_credentials_to('Other')
    @page.authorized_user_modal.wait_until_specify_other_credentials_visible
  end

  def when_i_fill_out_the_other_fields
    @page.authorized_user_modal.specify_other_credentials.set('asdf')
    @page.authorized_user_modal.specify_other_role.set('asdf')
  end

  def when_i_submit_the_form
    @page.authorized_user_modal.save_button.click
  end

  def when_i_have_an_error
    when_i_set_the_credentials_to('Other')
  end

  def then_i_should_see_the_add_authorized_user_dialog
    expect(@page).to have_authorized_user_modal
  end

  def then_i_should_see_the_users_basic_information
    expect(@page.authorized_user_modal).to have_css('label', text: 'Jane Doe')
  end

  def then_i_should_see_the_highest_level_of_rights_selected
    expect(@page.authorized_user_modal.approve_rights).to be_checked
  end

  def then_i_should_see_the_user_has_been_added
    @page.wait_for_authorized_users(text: /Jane Doe.*Co-Investigator.*Request\/Approve Services/)
    expect(@page).to have_authorized_users(text: /Jane Doe.*Co-Investigator.*Request\/Approve Services/)
  end

  def then_i_should_see_the_warning_message
    expect(page).to have_text("**WARNING**")
  end

  def then_i_should_see_the_new_primary_pi
    wait_for_javascript_to_finish
    #TODO: Implement feature to reload PD/PIs on Protocol Tab when a new user / edit user is done
    #expect(page).to_not have_selector(".protocol-accordion-title", text: "Julia Glenn")
    #expect(page).to have_selector(".protocol-accordion-title", text: "Brian Kelsey")
    within(find('.panel', text: 'Authorized Users')) do
      expect(page).to have_selector('td', text: 'Jane Doe')
      expect(page).to have_selector('td', text: 'Primary PI')
    end

    expect(protocol.reload.primary_principal_investigator).to eq(other_user)
  end

  def then_i_should_see_the_old_primary_pi_is_a_general_user
    wait_for_javascript_to_finish
    expect(ProjectRole.where(identity_id: logged_in_user.id, protocol_id: protocol.id).first.role).to eq('general-access-user')
  end

  def then_i_should_see_the_old_primary_pi_has_request_rights
    wait_for_javascript_to_finish
    expect(ProjectRole.find_by(identity_id: logged_in_user.id, protocol_id: protocol.id).project_rights).to eq('request')
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'other fields'
        expect(page).to have_text("Must specify this User's Role.")
        expect(page).to have_text("Must specify this User's Credentials.")
      when 'fields missing'
        expect(page).to have_text("Role can't be blank")
        expect(page).to have_text("Project rights can't be blank")
      when 'user already added'
        expect(page).to have_text("This user is already associated with this protocol.")
      when 'no access'
        expect(page).to have_text("You do not have appropriate rights to")
      when 'other credentials'
        expect(page).to have_text("Must specify this User's Credentials.")
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
