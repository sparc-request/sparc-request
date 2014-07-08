require 'spec_helper'

describe "editing a project", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
 
  before :each do
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    click_on("Project/Study Information")
    wait_for_javascript_to_finish
  end

  after :each do
    wait_for_javascript_to_finish
  end

  context "validations" do

    it "should raise an error message if study's status is pending and no potential funding source is selected" do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Select a Potential Funding Source", from: "Potential Funding Source")
      click_button "Save"
      page.should have_content("1 error prohibited this project from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "project_funding_source")
      click_button "Save"
      page.should have_content("1 error prohibited this project from being saved")
    end
  end

  context "clicking cancel button" do

    it "should not save changes" do
      fill_in "project_short_title", with: "Jason"
      find(".admin_cancel_link").click()    
      find("#project_short_title").should_not have_text("Jason")
    end
  end

  context "editing the short title" do

    it "should save the new short title" do
      fill_in "project_short_title", with: "Julius"
      click_button "Save"
      find("#project_short_title").should have_value("Julius")
    end
  end

  context "editing the project title" do

    it "should save the new project title" do
      fill_in "project_title", with: "Swanson"
      click_button "Save"
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
      click_button "Save"
      find("#project_brief_description").should have_value("This is an amazing description.")
    end
  end

  context "editing the indirect cost rate" do

    it "should save the indirect cost rate" do
      # TODO: this test seems to exhibit different behavior on sqlite
      # and mysql if 51.0 is used instead of 51.1.  It has to do, I
      # think, with sqlite not returning exactly the same object in
      # #show as it used in #update_from_project_study_information,
      # resulting in #indirect_cost_rate_before_type_cast returning 51
      # instead of "51.0".
      fill_in "project_indirect_cost_rate", with: "51.1"
      click_button "Save"
      wait_for_javascript_to_finish
      find("#project_indirect_cost_rate").should have_value("51.1")
    end
  end
end
