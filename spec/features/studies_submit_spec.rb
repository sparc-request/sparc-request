require 'spec_helper'

describe "creating a new study " do 

  before :each do
    visit root_path
    sleep 1
    visit new_service_request_study_path 1
    sleep 1
    find(:xpath, "//input[@alt='SaveAndContinue']").click
    sleep 1
  end

  describe "submitting a blank form" do

    it "should show errors when submitting a blank form", :js => true do
      find('#errorExplanation').visible?().should eq(true)
      sleep 1
    end

    it "should require a protocol title", :js => true do
      page.should have_content("Title can't be blank")
      sleep 1
    end
  end

  describe "submitting a filled form", :js => true do

    it "should clear errors and submit the form" do
      fill_in "study_short_title", :with => "Bob"
      fill_in "study_title", :with => "Dole"
      select "Funded", :from => "study_funding_status"
      select "Federal", :from => "study_funding_source"

      select "PD/PI", :from => "project_role_role"
      click_button "Add Authorized User"
      sleep 1

      find(:xpath, "//input[@alt='SaveAndContinue']").click
      sleep 2

      find("#service_request_protocol_id").value().should eq("1")
    end
  end
end