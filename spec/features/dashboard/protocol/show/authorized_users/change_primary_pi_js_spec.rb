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

RSpec.feature 'User messes with the change Primary PI Warning Dialog JS', js: true do
  let_there_be_lane
  let_there_be_j

  before(:each) do
    stub_const('USE_LDAP', false)
  end

  let!(:protocol) do
    protocol = create(:protocol_federally_funded,
      :without_validations,
      primary_pi: jug2,
      type: 'Project',
      archived: false)
    protocol
  end

  context 'under the Add Functionality' do
    before :each do
      fake_login

      visit "/dashboard/protocols/#{protocol.id}"
      wait_for_javascript_to_finish
    end

    context 'and submits the changes' do
      scenario 'and sees the warning message, sees the dialog changes, doesnt see the form, and doesnt see the search box' do
        given_i_have_clicked_the_add_authorized_user_button
        when_i_search_and_select_the_user
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_add
        then_i_should_see_the 'warning'
        then_i_should_see_the 'warning text add'
        then_i_should_not_see_the 'add form'
        then_i_should_not_see_the 'search'
      end

      context 'and clicks No' do
        scenario 'and sees the form, sees the dialog changes, and doesnt see the warning message' do
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_add
          when_i_cancel_in_add
          then_i_should_see_the 'add form'
          then_i_should_see_the 'add text'
          then_i_should_not_see_the 'warning'
        end
      end
    end
  end

  context 'under the Edit Functionality' do
    before(:each) do
      create(:project_role,
        protocol_id:     protocol.id,
        identity_id:     jpl6.id,
        project_rights:  'approve',
        role:            'business-grants-manager')

      fake_login

      visit "/dashboard/protocols/#{protocol.id}"
      wait_for_javascript_to_finish
    end

    context 'and submits the changes' do
      scenario 'and sees the warning message' do
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_see_the 'warning'
      end

      scenario 'and sees the dialog changes' do
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_see_the 'warning text edit'
      end

      scenario 'and doesnt see the form' do
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_not_see_the 'edit form'
      end

      context 'and clicks No' do
        scenario 'and sees the form' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_see_the 'edit form'
        end

        scenario 'and sees the dialog changes' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_see_the 'edit text'
        end

        scenario 'and doesnt see the warning message' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_not_see_the 'warning'
        end
      end

      context 'and closes and reopens the dialog' do
        scenario 'and sees the form' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_see_the 'edit form'
        end

        scenario 'and sees the dialog changes' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_see_the 'edit text'
        end

        scenario 'and doesnt see the warning message' do
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_not_see_the 'warning'
        end
      end
    end
  end

  def add_view_only_user_to_protocol
    create(:project_role,
      identity: jpl6,
      protocol: protocol,
      project_rights: 'view',
      role: 'mentor')
  end

  def given_i_have_clicked_the_add_authorized_user_button
    find_button('Add an Authorized User').click
  end

  def given_i_have_clicked_the_edit_authorized_user_button
    all(".edit-associated-user-button", visible: true)[1].click()
  end

  def when_i_search_and_select_the_user
    find('input[placeholder="Search for a User"]').set('Jason Leonard')
    expect(page).to have_css('.tt-selectable', text: 'Jason Leonard', visible: true)
    find('.tt-selectable', text: 'Jason Leonard', visible: true).click
  end

  def when_i_set_the_user_to_primary_pi
    expect(page).to have_css('button[data-id="project_role_role"]')
    find('button[data-id="project_role_role"]').click
    first('li a', text: 'Primary PI').click
    expect(page).to have_css("button[title='Primary PI']")
  end

  def when_i_submit_in_add
    click_button('save_protocol_rights_button')
  end

  def when_i_submit_in_edit
    click_button('save_protocol_rights_button')
  end

  def when_i_cancel_in_add
    find('button', text: 'Close').click
  end

  def when_i_cancel_in_edit
    find('button', text: 'Close').click
  end

  def when_i_exit
    find('button.close').click
  end

  def when_i_reopen_the_add_dialog
    given_i_have_clicked_the_add_authorized_user_button
  end

  def when_i_reopen_the_edit_dialog
    given_i_have_clicked_the_edit_authorized_user_button
  end

  def then_i_should_see_the obj_str
    case obj_str
      when 'add form'
        expect(page).to have_selector("form#new_project_role", visible: true)
      when 'search'
        expect(page).to have_selector('input[placeholder="Search for a User"]', visible: true)
      when 'add text'
        expect(page).to have_selector('#modal-title', visible: true, text: 'Add Authorized User')
        expect(page).to have_selector('button', visible: true, text: 'Save')
        expect(page).to have_selector('button', visible: true, text: 'Close')
      when 'edit form'
        expect(page).to have_selector('form.protocol_role_form', visible: true)
      when 'edit text'
        expect(page).to have_selector('h4', visible: true, text: 'Edit Authorized User')
        expect(page).to have_selector('button', visible: true, text: 'Save')
        expect(page).to have_selector('button', visible: true, text: 'Close')
      when 'warning'
        expect(page).to have_text("**WARNING**")
        expect(page).to have_text("Adding the new Primary PI")
        expect(page).to have_text("Do you wish to proceed?")
      when 'warning text add'
        expect(page).to have_text('will change the current Primary PI')
      when 'warning text edit'
        expect(page).to have_text('will change the current Primary PI')
        expect(page).to have_selector('button', visible: true, text: 'Save')
        expect(page).to have_selector('button', visible: true, text: 'Close')
      else
        puts "An unexpected error was found in then_i_should_see_the. Perhaps there was a typo in the test?"
        expect(0).to eq(1)
    end
  end

  def then_i_should_not_see_the obj_str
    case obj_str
      when 'add form'
        expect(page).to_not have_selector("form#new_project_role", visible: true)
      when 'search'
        expect(page).to_not have_selector("input#user_search", visible: true)
      when 'edit form'
        expect(page).to_not have_selector("form.associated_users_form", visible: true)
      when 'warning'
        expect(page).to_not have_text("**WARNING**")
        expect(page).to_not have_text("Adding the new Primary PI")
        expect(page).to_not have_text("Do you wish to proceed?")
      else
        puts "An unexpected error was found in then_i_should_not_see_the. Perhaps there was a typo in the test?"
        expect(0).to eq(1)
    end
  end
end
