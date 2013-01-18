require 'spec_helper'

describe "editing a study", js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_project()
 
  before :each do
    visit edit_portal_protocol_path service_request.protocol.id
  end

  context "validations" do

    it "should raise an error message if study's status is pending and no potential funding source is selected" do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Select a Potential Funding Source", from: "Potential Funding Source")
      click_button "Save project"
      page.should have_content("1 error prohibited this project from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "project_funding_source")
      click_button "Save project"
      page.should have_content("1 error prohibited this project from being saved")
    end
  end
end