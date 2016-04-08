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
  let!(:logged_in_user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           college: "college_of_medicine",
           department: "other",
           credentials: "ba",
           institution: "medical_university_of_south_carolina",
           approved: true)
  end

  let!(:other_user) do
    create(:identity,
           last_name: "Doe",
           first_name: "Jane",
           ldap_uid: "janed",
           email: "janed@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  before(:each) { stub_const('USE_LDAP', false) }

  let!(:protocol) do
    protocol = create(:unarchived_project_without_validations, primary_pi: logged_in_user)
    ProjectRole.create(
      protocol_id:     protocol.id,
      identity_id:     other_user.id,
      project_rights:  'approve',
      role:            'business-grants-manager')
    protocol
  end

  context 'and has permission to edit the protocol' do
    fake_login_for_each_test("johnd")

    before :each do
      # navigate to page
      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: protocol.id)
      wait_for_javascript_to_finish
    end

    context 'and clicks the Edit Authorized User button' do
      scenario 'and sees the Edit Authorized User dialog and the users information' do
        given_i_have_clicked_the_edit_authorized_user_button("John Doe")
        then_i_should_see_the_edit_authorized_user_dialog
        then_i_should_see_the_user_information
      end

      context 'and the Authorized User is the Primary PI and tries to change their role' do
        scenario 'and sees that the protocol must have a Primary PI' do
          given_i_have_clicked_the_edit_authorized_user_button("John Doe")
          when_i_set_the_role_to 'PD/PI'
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'need Primary PI'
        end
      end

      context 'and the authorized user is the primary PI and submits the form' do
        scenario 'and does not see the warning message' do
          given_i_have_clicked_the_edit_authorized_user_button("John Doe")
          when_i_submit_the_form
          then_i_should_not_see_the_warning_message
        end
      end

      context 'and the Authorized User is not the Primary PI and tries to make them the Primary PI' do
        context 'and submits the form' do
          scenario 'and sees the warning message' do
            given_i_have_clicked_the_edit_authorized_user_button("Jane Doe")
            when_i_set_the_role_to 'Primary PI'
            when_i_submit_the_form
            then_i_should_see_the_warning_message
          end

          context 'and submits the form on the warning message' do
            scenario 'and sees the Primary PI has changed, old primary pi is a general access user with request rights' do
              given_i_have_clicked_the_edit_authorized_user_button("Jane Doe")
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_new_primary_pi
              then_i_should_see_the_old_primary_pi_is_a_general_user
              then_i_should_see_the_old_primary_pi_has_request_rights
            end

            context 'with errors in the form' do
              scenario 'and sees errors' do
                given_i_have_clicked_the_edit_authorized_user_button("Jane Doe")
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

      context 'and sets the role and credentials to other, makes the extra fields empty, and submits the form' do
        scenario 'and sees some errors' do
          given_i_have_clicked_the_edit_authorized_user_button("John Doe")
          when_i_set_the_role_and_credentials_to_other
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'other fields'
        end
      end
    end
  end

  context 'and does not have permission to edit the protocol' do
    fake_login_for_each_test("janed")

    before :each do
      protocol = create(:unarchived_study_without_validations, primary_pi: logged_in_user)

      ProjectRole.create(
        protocol_id:     protocol.id,
        identity_id:     other_user.id,
        project_rights:  'view',
        role:            'mentor')

      # navigate to page
      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: protocol.id)
      wait_for_javascript_to_finish
    end

    scenario 'and sees disabled Add an Authorized User button' do
      expect(page).to have_css('.edit-associated-user-button.disabled')
    end
  end

  def given_i_have_clicked_the_edit_authorized_user_button(name)
    @page.authorized_users(text: name).first.edit_button.click
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

  def when_i_set_the_role_and_credentials_to_other
    when_i_set_the_role_to('Other')
    @page.authorized_user_modal.wait_until_specify_other_role_visible
    when_i_set_the_credentials_to('Other')
    @page.authorized_user_modal.wait_until_specify_other_credentials_visible
  end

  def when_i_submit_the_form
    @page.authorized_user_modal.save_button.click
  end

  def when_i_have_an_error
    when_i_set_the_credentials_to('Other')
  end

  def when_i_submit_the_form_and_confirm
    accept_confirm do
      @page.authorized_user_modal.save_button.click
    end
    wait_for_javascript_to_finish
  end

  def then_i_should_see_the_edit_authorized_user_dialog
    expect(@page).to have_authorized_user_modal
  end

  def then_i_should_see_the_user_information
    expect(@page.authorized_user_modal).to have_content("John Doe (johnd@musc.edu) #{logged_in_user.phone}")
    expect(@page.authorized_user_modal).to have_credentials_dropdown(text: "BA")
    expect(@page.authorized_user_modal).to have_institution_dropdown(text: "Medical University of South Carolina")
    expect(@page.authorized_user_modal).to have_college_dropdown(text: "College of Medicine")
    expect(@page.authorized_user_modal).to have_department_dropdown(text: "Other")
    expect(@page.authorized_user_modal).to have_role_dropdown(text: "Primary PI")
  end

  def then_i_should_see_the_warning_message
    expect(@page).to have_text("**WARNING**")
  end

  def then_i_should_not_see_the_warning_message
    expect(@page).to_not have_text("**WARNING**")
  end

  def then_i_should_see_the_new_primary_pi
    wait_for_javascript_to_finish
    expect(@page).to have_authorized_users(text: /Jane Doe.*Primary PI/)
    #TODO: Implement feature to reload PD/PIs on Protocol Tab when a new user / edit user is done

    expect(protocol.reload.primary_principal_investigator).to eq(other_user)
  end

  def then_i_should_see_the_old_primary_pi_is_a_general_user
    wait_for_javascript_to_finish
    expect(ProjectRole.find_by(identity_id: logged_in_user.id, protocol_id: protocol.id).role).to eq('general-access-user')
  end

  def then_i_should_see_the_old_primary_pi_has_request_rights
    wait_for_javascript_to_finish
    expect(ProjectRole.find_by(identity_id: logged_in_user.id, protocol_id: protocol.id).project_rights).to eq('request')
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'need Primary PI'
        expect(page).to have_text("Role - Protocols must have a Primary PI.")
      when 'no access'
        expect(page).to have_text("You do not have appropriate rights to")
      when 'role blank'
        expect(page).to have_text("Role can't be blank")
      when 'other fields'
        expect(page).to have_text("Must specify this User's Role.")
        expect(page).to have_text("Must specify this User's Credentials.")
      when 'other credentials'
        expect(page).to have_text("Must specify this User's Credentials.")
    else
      puts "An unaccounted-for error was found in then_i_should_see_an_error_of_type. Perhaps there was a typo in the test?"
      expect(0).to eq(1)
    end
  end
end
