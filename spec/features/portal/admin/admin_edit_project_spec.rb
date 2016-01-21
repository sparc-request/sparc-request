# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe "editing a project", js: true do
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
      expect(page).to have_content("1 error prohibited this project from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "project_funding_source")
      click_button "Save"
      expect(page).to have_content("1 error prohibited this project from being saved")
    end
  end

  context "switching from project to study" do
    before :each do
      project.update_attribute(:selected_for_epic, nil)
      select 'Study', from: 'protocol_type'
      click_button "Change Type"
      wait_for_javascript_to_finish
    end

    it 'should update the can edit study column to true' do
      expect(Protocol.find(project.id).can_edit_study).to eq true
    end

    it 'should have epic info box editable' do
      expect(page).to have_selector('#study_selected_for_epic_true')
    end

    it 'should not be editable' do
      find('#study_selected_for_epic_true').click()
      wait_for_javascript_to_finish
      select 'Yes', from: "study_type_answer_certificate_of_conf_answer" 
      click_button 'Save'
      select 'Project', from: 'protocol_type'
      click_button "Change Type"
      wait_for_javascript_to_finish
      expect(Protocol.find(project.id).can_edit_study).to eq false
      expect(page).to_not have_selector('#study_selected_for_epic_true')
      select 'Study', from: 'protocol_type'
      click_button "Change Type"
      wait_for_javascript_to_finish
      expect(Protocol.find(project.id).can_edit_study).to eq false
      expect(page).to_not have_selector('#study_selected_for_epic_true')
    end

    it 'should throw an error message' do
      click_button 'Save'
      expect(Protocol.find(project.id).can_edit_study).to eq true
      expect(page).to have_content("Selected for epic is not included in the list")
    end
  end

  context "clicking cancel button" do

    it "should not save changes" do
      fill_in "project_short_title", with: "Jason"
      find(".admin_cancel_link").click()
      expect(find("#project_short_title")).not_to have_text("Jason")
    end
  end

  context "editing the short title" do

    it "should save the new short title" do
      fill_in "project_short_title", with: "Julius"
      click_button "Save"
      expect(find("#project_short_title")).to have_value("Julius")
    end
  end

  context "editing the project title" do

    it "should save the new project title" do
      fill_in "project_title", with: "Swanson"
      click_button "Save"
      expect(find("#project_title")).to have_value("Swanson")
    end
  end

  context "selecting a status of funded" do

    it "should cause the field 'funding source' to be visible" do
      select("Funded", from: "Proposal Funding Status")
      expect(find("#project_funding_source")).to be_visible
    end
  end

  context "selecting a status of pending" do

    it "should cause the field 'potential funding source' to be visible" do
      select("Pending Funding", from: "Proposal Funding Status")
      expect(find("#project_potential_funding_source")).to be_visible
    end
  end

  context "selecting a funding/pending funding source" do

    it "should save the new funding source" do
      select("Funded", from: "Proposal Funding Status")
      select("Federal", from: "project_funding_source")
      expect(find("#project_funding_source")).to have_value("federal")
    end

    it "should save the new pending funding source" do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Federal", from: "Potential Funding Source")
      expect(find("#project_potential_funding_source")).to have_value("federal")
    end
  end

  context "editing the brief description" do

    it "should save the brief description" do
      fill_in "project_brief_description", with: "This is an amazing description."
      click_button "Save"
      expect(find("#project_brief_description")).to have_value("This is an amazing description.")
    end
  end
end
