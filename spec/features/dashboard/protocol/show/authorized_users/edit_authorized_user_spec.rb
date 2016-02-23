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

  let!(:protocol) do
    create(:protocol_federally_funded,
      :without_validations,
      primary_pi: jug2,
      type: 'Study',
      archived: false)
  end

  context 'and has permission to edit the protocol' do

    before :each do
      fake_login
      visit "/dashboard/protocols/#{protocol.id}"
      wait_for_javascript_to_finish
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

      context 'and the Authorized User is the Primary PI and tries to change their role' do
        scenario 'and sees that the protocol must have a Primary PI' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_role_to 'PD/PI'
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'need Primary PI'
        end
      end

      context 'and the authorized user is the primary PI and submits the form' do
        scenario 'and does not see the warning message' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_submit_the_form
          then_i_should_not_see_the_warning_message
        end
      end

      context 'and the Authorized User is not the Primary PI and tries to make them the Primary PI' do
        before :each do
          create(:project_role,
            protocol_id:     protocol.id,
            identity_id:     jpl6.id,
            project_rights:  'approve',
            role:            'business-grants-manager')
          fake_login 'jpl6@musc.edu'

          visit "/dashboard/protocols/#{protocol.id}"
        end

        context 'and submits the form' do
          scenario 'and sees the warning message' do
            given_i_have_clicked_the_edit_authorized_user_button 2
            when_i_set_the_role_to 'Primary PI'
            when_i_submit_the_form
            then_i_should_see_the_warning_message
          end

          context 'and submits the form on the warning message' do
            scenario 'and sees the Primary PI has changed' do
              given_i_have_clicked_the_edit_authorized_user_button 2
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_new_primary_pi
            end

            scenario 'and sees the old primary pi is a general access user' do
              given_i_have_clicked_the_edit_authorized_user_button 2
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_old_primary_pi_is_a_general_user
            end

            scenario 'and sees the old primary pi has request rights' do
              given_i_have_clicked_the_edit_authorized_user_button 2
              when_i_set_the_role_to 'Primary PI'
              when_i_submit_the_form
              when_i_submit_the_form
              then_i_should_see_the_old_primary_pi_has_request_rights
            end

            context 'with errors in the form' do
              scenario 'and sees errors' do
                given_i_have_clicked_the_edit_authorized_user_button 2
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
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_role_and_credentials_to_other
          when_i_submit_the_form
          then_i_should_see_an_error_of_type 'other fields'
        end
      end
    end
  end

  context 'and does not have permission to edit the protocol' do
    before :each do
      protocol = create(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Study',
        archived: false)

      create(:project_role,
        protocol_id:     protocol.id,
        identity_id:     jpl6.id,
        project_rights:  'view',
        role:            'mentor')
      fake_login 'jpl6@musc.edu'

      visit "/dashboard/protocols/#{protocol.id}"
      wait_for_javascript_to_finish
    end

    context 'and clicks the Edit Authorized User button' do
      scenario 'and sees some errors' do
        given_i_have_clicked_the_edit_authorized_user_button
        then_i_should_see_an_error_of_type 'no access'
      end
    end
  end

  def given_i_have_clicked_the_edit_authorized_user_button button_number=1
    all(".edit-associated-user-button", visible: true)[button_number-1].click()
  end

  def when_i_set_the_role_to role
    expect(page).to have_css('button[data-id="project_role_role"]')
    find('button[data-id="project_role_role"]').click
    first('li a', text: role).click
    expect(page).to have_css("button[title='#{role}']")
  end

  def when_i_set_the_credentials_to credentials
    select credentials, from: 'identity_credentials'
  end

  def when_i_set_the_role_and_credentials_to_other
    when_i_set_the_role_to 'Other'
    when_i_set_the_credentials_to 'Other'
  end

  def when_i_submit_the_form
    click_button('save_protocol_rights_button')
  end

  def when_i_have_an_error
    when_i_set_the_credentials_to 'Other'
  end

  def when_i_submit_the_form_and_confirm
    accept_confirm do
      click_button("edit_authorized_user_submit_button")
    end
    wait_for_javascript_to_finish
  end

  def then_i_should_see_the_edit_authorized_user_dialog
    expect(page).to have_text('Edit Authorized User')
  end

  def then_i_should_see_the_user_information
    expect(page).to have_css('label', text: "Julia Glenn (glennj@musc.edu) #{jug2.phone}")
    # jug2_pr = ProjectRole.find_by_identity_id(jug2.id)
    # expect(page).to have_css('label', text: "#{jug2.first_name} #{jug2.last_name}", visible: true)
    # expect(find('#email', visible: true)).to have_value(jug2.email)
    # expect(find('#identity_phone', visible: true)).to have_value(jug2.phone)
    # expect(find('#project_role_role', visible: true)).to have_value(jug2_pr.role)
  end

  def then_i_should_see_the_warning_message
    expect(page).to have_text("**WARNING**")
  end

  def then_i_should_not_see_the_warning_message
    expect(page).to_not have_text("**WARNING**")
  end

  def then_i_should_see_the_new_primary_pi
    wait_for_javascript_to_finish
    #TODO: Implement feature to reload PD/PIs on Protocol Tab when a new user / edit user is done
    #expect(page).to_not have_selector(".protocol-accordion-title", text: "Julia Glenn")
    #expect(page).to have_selector(".protocol-accordion-title", text: "Brian Kelsey")
    within(find('.panel', text: 'Authorized Users')) do
      expect(page).to have_selector('td', text: 'Jason Leonard')
      expect(page).to have_selector('td', text: 'Primary PI')
    end

    expect(protocol.reload.primary_principal_investigator).to eq(jpl6)
  end

  def then_i_should_see_the_old_primary_pi_is_a_general_user
    wait_for_javascript_to_finish
    expect(ProjectRole.where(identity_id: jug2.id, protocol_id: Protocol.first.id).first.role).to eq('general-access-user')
  end

  def then_i_should_see_the_old_primary_pi_has_request_rights
    wait_for_javascript_to_finish
    expect(ProjectRole.find_by(identity_id: jug2.id, protocol_id: Protocol.first.id).project_rights).to eq('request')
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
