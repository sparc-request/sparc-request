require 'spec_helper'

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
      sleep 1
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("draft")
    end
  end

  describe "clicking submit" do
    it 'Should submit the page', :js => true do
      find(:xpath, "//a/img[@alt='Confirm_request']/..").click
      sleep 1
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("submitted")
    end
  end

end
