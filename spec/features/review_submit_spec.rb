require 'spec_helper'

# TODO: I want to remove the sleeps from this page, but I can't because
# when I replace then with wait_for_javascript_to_finish, I get:
#
#      Failure/Error: wait_for_javascript_to_finish
#      Selenium::WebDriver::Error::JavascriptError:
#        ReferenceError: $ is not defined

describe "review page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit review_service_request_path service_request.id
  end

  describe "clicking save and exit/draft" do
    it 'Should save request as a draft' do
      find(:xpath, "//a/img[@alt='Wait_save_draft']/..").click

      # TODO: uncommenting this results in '$ is not defined', but
      # ideally we do need to wait for ajax requests to complete before
      # reading from the database
      # wait_for_javascript_to_finish

      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("draft")
    end
  end

  describe "clicking submit" do
    it 'Should submit the page' do
      find(:xpath, "//a/img[@alt='Confirm_request']/..").click
      wait_for_javascript_to_finish
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("submitted")
    end

    context 'epic emails' do

      before :each do
        project.project_roles.first.update_attributes(epic_access: true)
        EpicRight.create(:project_role_id => project.project_roles.first.id, :right => 'view_rights')

        service2.update_attributes(send_to_epic: true)
        clear_emails
        find(:xpath, "//a/img[@alt='Confirm_request']/..").click
        wait_for_javascript_to_finish
        @email = all_emails.find { |email| email.subject == "Epic Rights Approval"}
      end

      it 'should send an email to the Epic admins' do
        @email.should have_content "To approve the users and rights"
      end

      # Table is filled correctly
      it 'should have the correct users in the table' do
        visit_email @email
        project_role = project.project_roles.first

        page.should_not have_content project.project_roles.last.identity.full_name

        within("#project_role_#{project.project_roles.first.id}") do
          find(".name").should have_content project_role.identity.full_name
          find(".role").should have_content USER_ROLES.invert[project_role.role]
          find(".epic_rights").should have_content(EPIC_RIGHTS["view_rights"])
        end
      end

      # Primary PI link
      it 'should be able to click the send to primary pi link' do
        visit_email @email
        click_link "Send to Primary PI"
        page.should have_content "Thank you. An email has been sent to the primary PI for the final approval."
      end

      context 'primary pi emails' do
        before :each do
          visit_email @email
          clear_emails
          click_link "Send to Primary PI"
          @email = all_emails.find { |email| email.subject == "Epic Rights User Approval"}
        end

        it "should send an email to the Primary PI" do
          @email.should have_content("The following SPARC Request users have requested access to Epic for your study ##{project.id}")
        end

        it "should have the correct users in the table" do
          visit_email @email
          project_role = project.project_roles.first

          page.should_not have_content project.project_roles.last.identity.full_name

          within("#project_role_#{project.project_roles.first.id}") do
            find(".name").should have_content project_role.identity.full_name
            find(".role").should have_content USER_ROLES.invert[project_role.role]
            find(".epic_rights").should have_content(EPIC_RIGHTS["view_rights"])
          end
        end

        it "should send the study to epic" do
          visit_email @email
          click_link "Send to Epic"
          page.should have_content "Study has been sent to Epic"
        end
      end
    end
  end

end
