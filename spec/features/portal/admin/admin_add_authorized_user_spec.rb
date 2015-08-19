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

describe 'associated users tab', :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let!(:bob) { FactoryGirl.create(:identity,
    last_name:             'Dole',
    first_name:            'Bob',
    ldap_uid:              'bob',
    institution:           'medical_university_of_south_carolina',
    college:               'college_of_medecine',
    department:            'other',
    email:                 'bobdole@musc.edu',
    credentials:           'BS,    MRA',
    catalog_overlord:      true,
    password:              'p4ssword',
    password_confirmation: 'p4ssword',
    approved:              true
  )}

  before :each do
    identity = Identity.find_by_ldap_uid('bob')
    project_role = FactoryGirl.create(
      :project_role,
      protocol_id:     service_request.protocol.id,
      identity_id:     identity.id,
      project_rights:  "approve",
      role:            "co-investigator")
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    page.find('a', :text => "Associated Users", :visible => true).click()
  end
  describe 'adding an authorized user' do

    before :each do
      page.find(".associated-user-button", :visible => true).click()
      wait_for_javascript_to_finish
    end

    describe 'clicking the add button' do
      it "should show add authorized user dialog box" do
        expect(page).to have_text 'Add User'
      end
    end

    describe 'searching for an user' do
      before :each do
        fill_autocomplete('user_search', with: 'bjk7');
        page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
      end

      it 'should remove the black shield' do
        page.should_not have_selector('#shield')
      end

      it 'should display the users information' do
        find('#full_name').should have_value 'Brian Kelsey'
      end

      describe 'submitting the user' do
        it 'should add the user to the study/project' do
          select "Co-Investigator", :from => 'project_role_role'
          choose 'project_role_project_rights_request'
          click_button("add_authorized_user_submit_button")

          within('#users') do
            page.should have_text('Brian Kelsey')
            page.should have_text('Co-Investigator')
            page.should have_text('Request/Approve Services')
          end
        end

        it 'should throw errors when missing a role or project rights' do
          # Wait for form to activate before we submit.
          # Submitting too fast before this has occured will
          # send the controller no protocol id.
          expect(find('#full_name')).to have_value 'Brian Kelsey'
          click_button("add_authorized_user_submit_button")
          page.should have_text "Role can't be blank"
          page.should have_text "Project_rights can't be blank"
        end

        it 'should throw an error when adding the same person twice' do
          select "Co-Investigator", :from => 'project_role_role'
          choose 'project_role_project_rights_request'
          click_button("add_authorized_user_submit_button")

          page.find(".associated-user-button", visible: true).click()

          fill_autocomplete('user_search', with: 'bjk7')
          page.find('a', text: "Brian Kelsey", visible: true).click()

          select "Co-Investigator", :from => 'project_role_role'
          choose 'project_role_project_rights_request'
          click_button("add_authorized_user_submit_button")

          page.should have_text "This user is already associated with this protocol."
        end
      end
    end
  end

  describe 'removing an authorized user' do

    describe 'clicking the remove button' do

      it 'should ask for confirmation' do
        accept_alert("Projects require a PI. Please add a new one before continuing.") do
          accept_confirm("Are you sure?") do
            within("#user_#{jug2.id}") do
              page.find('.delete-associated-user-button', visible: true).click
            end
          end
        end
      end

      it 'should not allow the only PD/PI to be removed' do
        accept_alert("Projects require a PI. Please add a new one before continuing.") do
          accept_confirm do
            within("#user_#{jug2.id}") do
              page.find('.delete-associated-user-button', visible: true).click
            end
          end
        end
      end
    end

    it 'should remove non PD/PIs from the list' do
      accept_confirm('Are you sure?') do
        within("#user_#{bob.id}") do
          page.find('.delete-associated-user-button', visible: true).click
        end
      end
      within('#users') do
        page.should_not have_selector("#user_#{bob.id}")
      end
    end
  end

  describe 'editing an authorized user' do
    it 'should not allow the only PD/PI to change roles' do
      within("#user_#{jug2.id}") do
        find('.edit-associated-user-button').click
      end
      page.find('#project_role_role', visible: true).select "Co-Investigator"
      click_button("edit_authorized_user_submit_button")
      page.should have_text 'Must include one Primary PI.'
    end

    it 'should open with the users information' do
      within("#user_#{jug2.id}") do
        find('.edit-associated-user-button').click
      end
      expect(find('#full_name', visible: true)).to have_value "Julia Glenn"
      expect(find('#email', visible: true)).to have_value "glennj@musc.edu"
    end

    it 'should allow user roles to change' do
      within("#user_#{bob.id}") do
        find('.edit-associated-user-button').click
      end
      page.find('#project_role_role', :visible => true).select 'Technician'
      click_button("edit_authorized_user_submit_button")

      within("#user_#{bob.id}") do
        page.should have_text "Technician"
      end
    end
  end
end
