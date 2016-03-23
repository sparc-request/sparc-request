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
  build_service_request_with_project

  before :each do
    fake_login 

    visit portal_root_path
    wait_for_javascript_to_finish
  end

  context 'under the Add Functionality' do
    context 'and submits the changes' do
      scenario 'and sees the warning message' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_add_authorized_user_button
        when_i_search_and_select_the_user
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_add
        then_i_should_see_the 'warning'
      end

      scenario 'and sees the dialog changes' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_add_authorized_user_button
        when_i_search_and_select_the_user
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_add
        then_i_should_see_the 'warning text add'
      end

      scenario 'and doesnt see the form' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_add_authorized_user_button
        when_i_search_and_select_the_user
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_add
        then_i_should_not_see_the 'add form'
      end

      context 'and clicks No' do
        scenario 'and sees the form' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_add
          when_i_cancel_in_add
          then_i_should_see_the 'add form'
        end

        scenario 'and sees the search box' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_add
          when_i_cancel_in_add
          then_i_should_see_the 'search'
        end

        scenario 'and sees the dialog changes' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_add
          when_i_cancel_in_add
          then_i_should_see_the 'add text'
        end

        scenario 'and doesnt see the warning message' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_add
          when_i_cancel_in_add
          then_i_should_not_see_the 'warning'
        end
      end

      context 'and closes and reopens the dialog' do
        scenario 'and sees the form' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_add_dialog
          then_i_should_see_the 'add form'
        end

        scenario 'and sees the search box' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_add_dialog
          then_i_should_see_the 'search'
        end

        scenario 'and sees the dialog changes' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_add_dialog
          then_i_should_see_the 'add text'
        end

        scenario 'and doesnt see the warning message' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_add_authorized_user_button
          when_i_search_and_select_the_user
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_add_dialog
          then_i_should_not_see_the 'warning'
        end
      end
    end
  end

  context 'under the Edit Functionality' do
    context 'and submits the changes' do

      scenario 'and sees the warning message' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_see_the 'warning'
      end

      scenario 'and sees the dialog changes' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_see_the 'warning text edit'
      end

      scenario 'and doesnt see the form' do
        given_that_i_have_selected_a_protocol
        given_i_have_clicked_the_edit_authorized_user_button
        when_i_set_the_user_to_primary_pi
        when_i_submit_in_edit
        then_i_should_not_see_the 'edit form'
      end

      context 'and clicks No' do
        scenario 'and sees the form' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_see_the 'edit form'
        end

        scenario 'and sees the dialog changes' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_see_the 'edit text'
        end

        scenario 'and doesnt see the warning message' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_submit_in_edit
          when_i_cancel_in_edit
          then_i_should_not_see_the 'warning'
        end
      end

      context 'and closes and reopens the dialog' do
        scenario 'and sees the form' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_see_the 'edit form'
        end

        scenario 'and sees the dialog changes' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_see_the 'edit text'
        end

        scenario 'and doesnt see the warning message' do
          given_that_i_have_selected_a_protocol
          given_i_have_clicked_the_edit_authorized_user_button
          when_i_set_the_user_to_primary_pi
          when_i_exit
          when_i_reopen_the_edit_dialog
          then_i_should_not_see_the 'warning'
        end
      end
    end
  end

  def given_that_i_have_selected_a_protocol
    eventually { first('.blue-provider').click }
  end

  def given_i_have_clicked_the_add_authorized_user_button
    eventually { find(".associated-user-button", visible: true).click }
  end

  def given_i_have_clicked_the_edit_authorized_user_button
    eventually { all(".edit-associated-user-button", visible: true)[1].click() }
  end

  def when_i_search_and_select_the_user
    fill_autocomplete('user_search', with: 'bjk7')
    page.find('a', text: "Brian Kelsey", visible: true).click
  end

  def when_i_set_the_user_to_primary_pi
    select "Primary PI", from: 'project_role_role'
  end

  def when_i_submit_in_add
    find("#add_authorized_user_submit_button").click
    wait_for_javascript_to_finish
  end

  def when_i_submit_in_edit
    find("#edit_authorized_user_submit_button").click
    wait_for_javascript_to_finish
  end

  def when_i_cancel_in_add
    find("#add_authorized_user_cancel_button").click
    wait_for_javascript_to_finish
  end

  def when_i_cancel_in_edit
    find("#edit_authorized_user_cancel_button").click
  end

  def when_i_exit
    find(".ui-dialog-titlebar button").click
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
        expect(page).to have_selector("input#user_search", visible: true)
      when 'add text'
        expect(page).to have_selector(".ui-dialog-title", visible: true, text: "Add an Authorized User")
        expect(page).to have_selector("#add_authorized_user_submit_button .ui-button-text", visible: true, text: "Submit")
        expect(page).to have_selector("#add_authorized_user_cancel_button .ui-button-text", visible: true, text: "Cancel")
      when 'edit form'
        expect(page).to have_selector("form.associated_users_form", visible: true)
      when 'edit text'
        expect(page).to have_selector(".ui-dialog-title", visible: true, text: "Edit an Authorized User")
        expect(page).to have_selector("#edit_authorized_user_submit_button .ui-button-text", visible: true, text: "Submit")
        expect(page).to have_selector("#edit_authorized_user_cancel_button .ui-button-text", visible: true, text: "Cancel")
      when 'warning'
        expect(page).to have_text("**WARNING**")
        expect(page).to have_text("Adding the new Primary PI")
        expect(page).to have_text("Do you wish to proceed?")
      when 'warning text add'
        expect(page).to have_selector(".ui-dialog-title", visible: true, text: "Change Primary PI")
        expect(page).to have_selector("#add_authorized_user_submit_button .ui-button-text", visible: true, text: "Yes")
        expect(page).to have_selector("#add_authorized_user_cancel_button .ui-button-text", visible: true, text: "No")
      when 'warning text edit'
        expect(page).to have_selector(".ui-dialog-title", visible: true, text: "Change Primary PI")
        expect(page).to have_selector("#edit_authorized_user_submit_button .ui-button-text", visible: true, text: "Yes")
        expect(page).to have_selector("#edit_authorized_user_cancel_button .ui-button-text", visible: true, text: "No")
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
