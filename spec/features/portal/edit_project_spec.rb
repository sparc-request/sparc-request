require 'spec_helper'

describe "editing a project", js: true do
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
      click_button "Save Project"
      page.should have_content("1 error prohibited this project from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "project_funding_source")
      click_button "Save Project"
      page.should have_content("1 error prohibited this project from being saved")
    end
  end

  context "cancel button" do

    it "should redirect back to the main portal page" do
      click_on "Cancel"
      page.should have_content("Welcome!")
    end
  end

  context "editing the short title" do

    it "should save the new short title" do
      fill_in "project_short_title", with: "Julius"
      click_button "Save Project"
      visit edit_portal_protocol_path service_request.protocol.id
      find("#project_short_title").should have_value("Julius")
    end
  end

  context "editing the project title" do

    it "should save the new project title" do
      fill_in "project_title", with: "Swanson"
      click_button "Save Project"
      visit edit_portal_protocol_path service_request.protocol.id
      find("#project_title").should have_value("Swanson")
    end
  end

  context "selecting a status of funded" do

    it "should cause the field 'funding source' to be visible" do
      select("Funded", from: "Proposal Funding Status")
      find("#project_funding_source").should be_visible
    end
  end

  context "selecting a status of pending" do

    it "should cause the field 'potential funding source' to be visible" do
      select("Pending Funding", from: "Proposal Funding Status")
      find("#project_potential_funding_source").should be_visible
    end
  end

  context "selecting a funding/pending funding source" do

    it "should save the new funding source" do
      select("Funded", from: "Proposal Funding Status")
      select("Federal", from: "project_funding_source")
      find("#project_funding_source").should have_value("federal")
    end

    it "should save the new pending funding source" do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Federal", from: "Potential Funding Source")
      find("#project_potential_funding_source").should have_value("federal")
    end
  end

  context "editing the brief description" do

    it "should save the brief description" do
      fill_in "project_brief_description", with: "This is an amazing description."
      click_button "Save Project"
      visit edit_portal_protocol_path service_request.protocol.id
      find("#project_brief_description").should have_value("This is an amazing description.")
    end
  end

  context "editing the indirect cost rate" do

    it "should save the indirect cost rate" do
      fill_in "project_indirect_cost_rate", with: "50.0"
      click_button "Save Project"
      visit edit_portal_protocol_path service_request.protocol.id
      find("#project_indirect_cost_rate").should have_value("50.0")
    end
  end
end
