require 'spec_helper'

# TODO: I want to remove the sleeps from this page, but I can't because
# when I replace then with wait_for_javascript_to_finish, I get:
#
#      Failure/Error: wait_for_javascript_to_finish
#      Selenium::WebDriver::Error::JavascriptError:
#        ReferenceError: $ is not defined

describe "review page" do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit review_service_request_path service_request.id
  end

  describe "clicking save and exit/draft" do
    it 'Should save request as a draft', :js => true do
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
    it 'Should submit the page', :js => true do
      find(:xpath, "//a/img[@alt='Confirm_request']/..").click
      wait_for_javascript_to_finish
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("submitted")
    end
  end

end
