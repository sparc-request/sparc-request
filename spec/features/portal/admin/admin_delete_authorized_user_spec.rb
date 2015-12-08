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

RSpec.feature 'User wants to delete an authorized user', js: true do
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

  def given_i_have_clicked_the_delete_authorized_user_button
    page.all('.delete-associated-user-button', visible: true)[1].click()
  end

  def given_i_have_clicked_the_delete_authorized_user_button_and_confirmed
    accept_confirm do
      page.all('.delete-associated-user-button', visible: true)[1].click()
    end
  end

  def given_i_have_clicked_the_delete_authorized_user_button_for_the_primary_pi
    accept_alert do
      first('.delete-associated-user-button', visible: true).click()
    end
  end

  def then_i_should_not_see_the_authorized_user
    expect(page).to_not have_text("Jason Leonard")
  end

  def then_i_should_see_an_error_of_type error_type
    case error_type
      when 'need Primary PI'
        #Because of deprecation, we can't directly access the alert.
        #Instead, we will test that the Primary PI is still there after
        #the confirm.
        expect(page).to have_text("Primary PI")
    else
      puts "An unexpected error was found in then_i_should_see_an_error_of_type. Perhaps there was a typo in the test?"
      expect(0).to eq(1)
    end
  end
end
