require 'spec_helper'
require 'ostruct'


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
      fill_in 'user_search', :with => 'bjk7'
      wait_for_javascript_to_finish
      page.find('a', :text => "Brian Kelsey", :visible => true).click()
      wait_for_javascript_to_finish
    end

    it 'should remove the black shield' do
      page.should_not have_selector('#shield')
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
