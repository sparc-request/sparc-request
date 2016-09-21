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

RSpec.feature 'User wants to delete an authorized user', js: true do
  let!(:logged_in_user) { create(:identity, last_name: "Doe", first_name: "John", ldap_uid: "johnd", email: "johnd@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  let!(:other_user) { create(:identity, last_name: "Doe", first_name: "Jane", ldap_uid: "janed", email: "janed@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  before(:each) { stub_const('USE_LDAP', false) }

  context 'which is not assigned to themself' do
    let!(:protocol) { create(:unarchived_project_without_validations, primary_pi: logged_in_user) }

    context 'and has access to the protocol' do
      fake_login_for_each_test("johnd")

      before :each do
        create(:project_role, protocol: protocol, identity: other_user, project_rights: 'view', role: 'mentor')

        # navigate to page
        @page = Dashboard::Protocols::ShowPage.new
        @page.load(id: protocol.id)
        wait_for_javascript_to_finish
      end

      context 'and tries to delete the Primary PI' do
        scenario 'and sees an error message' do
          given_i_have_clicked_the_delete_authorized_user_button_for_the_primary_pi
          then_i_should_see_an_error_of_type 'need Primary PI'
        end
      end

      context 'and tries to delete a user who is not the Primary PI' do
        scenario 'and sees the user is gone' do
          given_i_have_clicked_the_delete_authorized_user_button_and_confirmed
          then_i_should_not_see_the_authorized_user
        end
      end
    end

    context 'and does not have access to the protocol' do
      fake_login_for_each_test("janed")

      context 'and tries to delete the user' do
        scenario 'and sees disabled Delete an Authorized User button' do
          create(:project_role, protocol: protocol, identity: other_user, project_rights: 'view', role: 'mentor')

          # navigate to page
          page = Dashboard::Protocols::ShowPage.new
          page.load(id: protocol.id)

          expect(page).not_to have_css '.delete-associated-user-button:not(.disabled)'
          expect(page).to have_css '.delete-associated-user-button.disabled'
        end
      end
    end
  end

  context 'which is assigned to themself' do
    let!(:protocol) do
      protocol  = create(:unarchived_project_without_validations, primary_pi: other_user)
                  create(:project_role, protocol: protocol, identity: logged_in_user, project_rights: 'approve', role: 'mentor')
      protocol
    end

    fake_login_for_each_test("johnd")

    context 'and they are an Admin' do
      before :each do
        organization    = create(:organization)
        service_request = create(:service_request_without_validations, protocol: protocol)
                          create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                          create(:super_user, organization: organization, identity: logged_in_user)

        # navigate to page
        page = Dashboard::Protocols::ShowPage.new
        page.load(id: protocol.id)
        wait_for_javascript_to_finish

        page.authorized_users(text: "John Doe").first.enabled_remove_button.click
        wait_for_javascript_to_finish
      end

      scenario 'and should see the Edit Study Information button' do
        expect(page).to have_selector('.edit-protocol-information-button')
      end

      scenario 'and should see the Add/Edit/Delete Authorized User buttons enabled' do
        expect(page).to have_css '#new-associated-user-button:not(.disabled)'

        expect(page).not_to have_css '.edit-associated-user-button.disabled'
        expect(page).to have_css '.edit-associated-user-button:not(.disabled)'
        
        expect(page).not_to have_css '.delete-associated-user-button.disabled'
        expect(page).to have_css '.delete-associated-user-button:not(.disabled)'
      end
    end

    context 'and they are not an Admin' do
      scenario 'and is redirected to the Dashboard' do
        # navigate to page
        page = Dashboard::Protocols::ShowPage.new
        page.load(id: protocol.id)      
        wait_for_javascript_to_finish
        
        page.authorized_users(text: "John Doe").first.enabled_remove_button.click
        wait_for_javascript_to_finish

        expect(URI.parse(current_url).path).to eq("/dashboard")
      end
    end
  end

  def given_i_have_clicked_the_delete_authorized_user_button_and_confirmed
    @page.authorized_users(text: "Jane Doe").first.enabled_remove_button.click
  end

  def given_i_have_clicked_the_delete_authorized_user_button_for_the_primary_pi
    accept_alert do
      @page.authorized_users(text: "John Doe").first.enabled_remove_button.click
    end
  end

  def then_i_should_not_see_the_authorized_user
    expect(@page).to_not have_text("Jane Doe")
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'need Primary PI'
        #Because of deprecation, we can't directly access the alert.
        #Instead, we will test that the Primary PI is still there after
        #the confirm.
        expect(page).to have_text("Primary PI")
      when 'no access'
        expect(page).to have_text("You do not have appropriate rights to")
    else
      puts "An unexpected error was found in then_i_should_see_an_error_of_type. Perhaps there was a typo in the test?"
      expect(0).to eq(1)
    end
  end
end
