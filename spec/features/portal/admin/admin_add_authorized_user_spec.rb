require 'spec_helper'
require 'ostruct'

describe 'associated users tab', :js => true do
  let_there_be_lane
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
    Directory.stub(:search_ldap) {
      [
        OpenStruct.new(
          dn: ["uid=bjk7,ou=people,dc=musc,dc=edu"],
          givenname: [ 'Brian' ],
          sn: [ 'Kelsey' ],
          uid: [ 'bjk7' ],
          mail: [ 'kelsey@musc.edu' ]
        )
      ]
    }
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    page.find('a', :text => "Associated Users", :visible => true).click()
  end
  describe 'adding an authrozied user' do

    before :each do
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

      it 'should remove the black shield' do
        page.has_selector?('#shield').should eq false
      end

      it 'should display the users information' do
        find('#full_name').value.should eq 'Brian Kelsey'
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

  describe 'removing an authorized user' do

    describe 'clicking the remove button' do
      before :each do
        within("#user_#{jug2.id}") do
          page.find('.delete-associated-user-button', :visible => true).click
        end
        @a = page.driver.browser.switch_to.alert
      end

      it 'should ask for confirmation' do
        @a.text.should eq "Are you sure?"
        @a.accept
        @a.accept
      end

      it 'should not allow the only PD/PI to be removed' do
        @a.accept
        @a = page.driver.browser.switch_to.alert
        @a.text.should eq "Projects require a PI. Please add a new one before continuing."
        @a.accept
      end
    end

    it 'should remove non PD/PIs from the list' do
      within("#user_#{bob.id}") do
        page.find('.delete-associated-user-button', :visible => true).click
      end
      a = page.driver.browser.switch_to.alert
      a.accept
      wait_for_javascript_to_finish
      within('#users') do
        page.has_selector?("#user_#{bob.id}").should eq false
      end
    end
  end

  describe 'editing an authorized user' do
    it 'should not allow the only PD/PI to change roles' do
      within("#user_#{jug2.id}") do
        find('.edit-associated-user-button').click
      end
      wait_for_javascript_to_finish
      page.find('#project_role_role', :visible => true).select "Co-Investigator"
      click_button("edit_authorized_user_submit_button")
      page.should have_text 'Must include one PI.'
    end

    it 'should open with the users information' do
      within("#user_#{jug2.id}") do
        find('.edit-associated-user-button').click
      end
      wait_for_javascript_to_finish
      find('#full_name', :visible => true).value.should eq "Julia Glenn"
      find('#email', :visible => true).value.should eq "glennj@musc.edu"
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
      sleep 10
    end
  end
end