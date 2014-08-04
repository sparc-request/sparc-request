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

require 'spec_helper'

describe 'adding an authorized user', :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    visit portal_root_path
    page.find(".associated-user-button", :visible => true).click()
    wait_for_javascript_to_finish
  end

  describe 'clicking the add button' do
    it "should show add authrozied user dialog box" do
      page.should have_text 'Add User'
    end
  end

  describe 'searching for an user' do
    before :each do
      fill_in 'user_search', :with => 'bjk7'
      wait_for_javascript_to_finish
      page.find('a', :text => "Brian Kelsey", :visible => true).click()
      wait_for_javascript_to_finish
    end

    it 'should display the users information' do
      find('#full_name').should have_value 'Brian Kelsey'
    end

    describe 'setting the proper rights' do

      it 'should default to the highest rights for pi' do
        select "PD/PI", :from => 'project_role_role'
        find("#project_role_project_rights_approve").should be_checked()
      end

      it 'should default to the highest rights for billing/business manager' do
        select "Billing/Business Manager", :from => 'project_role_role'
        find("#project_role_project_rights_approve").should be_checked()
      end
    end

    describe 'submitting the user' do
      it 'should add the user to the study/project' do
        select "Co-Investigator", :from => 'project_role_role'
        choose 'project_role_project_rights_request'
        click_button("add_authorized_user_submit_button")

        within('.protocol-information-table') do
          page.should have_text('Brian Kelsey')
          page.should have_text('Co-Investigator')
          page.should have_text('Request/Approve Services')
        end
      end

      it 'should throw errors when missing a role or project rights' do
        click_button("add_authorized_user_submit_button")
        page.should have_text "Role can't be blank"
        page.should have_text "Project_rights can't be blank"
      end

      it 'should throw an error when adding the same person twice' do
        select "Co-Investigator", :from => 'project_role_role'
        choose 'project_role_project_rights_request'
        click_button("add_authorized_user_submit_button")
        wait_for_javascript_to_finish

        page.find(".associated-user-button", :visible => true).click()
        wait_for_javascript_to_finish

        fill_in 'user_search', :with => 'bjk7'
        wait_for_javascript_to_finish
        page.find('a', :text => "Brian Kelsey", :visible => true).click()
        wait_for_javascript_to_finish

        select "Co-Investigator", :from => 'project_role_role'
        choose 'project_role_project_rights_request'
        click_button("add_authorized_user_submit_button")

        page.should have_text "This user is already associated with this protocol."
      end
    end
  end
end
