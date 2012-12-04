require 'spec_helper'

describe "submitting a in form" do
  build_service_request_with_project


  describe "submitting an empty form" do
    it "Should throw errors", :js => true do
      visit service_details_service_request_path service_request.id
      sleep 1
      fill_in "service_request_visit_count", :with => ""
      fill_in "service_request_subject_count", :with => ""
      sleep 1
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      sleep 2
      find("#errorExplanation").should have_content("You must specify the estimated total number of visits")
      find("#errorExplanation").should have_content("You must specify the estimated total number of subjects")
    end
  end

  describe "submitting a completed form" do
    it 'Should pass, and submit', :js => true do
      visit service_details_service_request_path service_request.id
      sleep 1
      fill_in "service_request_subject_count", :with => "4"
      fill_in "service_request_visit_count", :with => "20"
      sleep 1
      find(:xpath, "//a/img[@alt='Savecontinue']/..").click
      sleep 2
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.subject_count.should eq(4)
      service_request_test.visit_count.should eq(20)
    end
  end

end
