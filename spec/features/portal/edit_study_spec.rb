require 'spec_helper'

describe "editing a study", js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_study()
  
  before :each do
    visit edit_portal_protocol_path service_request.id
  end

  context "saving a study" do

    it "should redirect to the main portal page" do
      click_button "Save study"
      page.should have_content("Welcome!")
    end
  end

  context "editing the short title" do

    it "should save the short title" do
      fill_in "study_short_title", with: "Bob"
      click_button "Save study"
      visit edit_portal_protocol_path service_request.id
      find("#study_short_title").value().should eq("Bob")
    end
  end

  context "editing the protocol title" do

    it "should save the protocol title" do
      fill_in "study_title", with: "Slappy"
      click_button "Save study"
      visit edit_portal_protocol_path service_request.id
      find("#study_title").value().should eq("Slappy")
    end
  end

  context "selecting a funding status" do

    it "should add 'potential' fields if status is pending" do
      select("Pending Funding", from: "Proposal Funding Status")
      page.should have_content("Potential Funding Start Date:")
    end

    it "should add 'funding' fields if status is funded" do
      select("Funded", from: "Proposal Funding Status")
      page.should have_content("Funding Start Date:")
    end
  end
end