require 'spec_helper'

describe "submitting a in form" do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    visit service_details_service_request_path service_request.id
  end


  describe "submitting an empty form" do
    it "Should throw errors", :js => true do
      fill_in "service_request_visit_count", :with => ""
      fill_in "service_request_subject_count", :with => ""

      wait_for_javascript_to_finish

      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish

      find("#errorExplanation").should have_content("You must specify the estimated total number of visits")
      find("#errorExplanation").should have_content("You must specify the estimated total number of subjects")
    end
  end

  describe "submitting a completed form" do
    it 'Should pass, and submit', :js => true do
      fill_in "service_request_subject_count", :with => "4"
      fill_in "service_request_visit_count", :with => "20"
      wait_for_javascript_to_finish

      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      wait_for_javascript_to_finish

      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.subject_count.should eq(4)
      service_request_test.visit_count.should eq(20)
    end
  end

end
