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

require 'spec_helper'

describe "editing a study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study()
 
  let(:numerical_day) { Date.today.strftime("%d").gsub(/^0/,'') }

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
      click_button "Save"
      wait_for_javascript_to_finish
      page.should have_content("1 error prohibited this study from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "study_funding_source")
      click_button "Save"
      wait_for_javascript_to_finish
      page.should have_content("1 error prohibited this study from being saved")
    end
  end

  context "editing the short title" do

    it "should save the new short title" do
      fill_in "study_short_title", with: "Bob"
      click_button "Save"
      wait_for_javascript_to_finish
      find("#study_short_title").should have_value("Bob")
    end
  end

  context "clicking cancel button" do

    it "should not save changes" do
      fill_in "study_short_title", with: "Jason"
      find(".admin_cancel_link").click()    
      find("#study_short_title").should_not have_text("Jason")
    end
  end

  context "editing the protocol title" do

    it "should save the new protocol title" do
      fill_in "study_title", with: "Slappy"
      click_button "Save"
      find("#study_title").should have_value("Slappy")
    end
  end

  context "selecting a funding status" do

    it "should change to pending funding" do
      select("Pending Funding", from: "Proposal Funding Status")
      find("#study_funding_status").should have_value("pending_funding")
    end

    it "should change to funded" do
      select("Funded", from: "Proposal Funding Status")
      find("#study_funding_status").should have_value("funded")
    end
  end

  context "editing the UDAK/Project #" do

    it "should save the new udak/project number" do
      fill_in "study_udak_project_number", with: "12345"
      click_button "Save"
      find("#study_udak_project_number").should have_value("12345")
    end    
  end

  context "editing the sponsor name" do

    it "should save the new sponsor name" do
      fill_in "study_sponsor_name", with: "Kurt Zanzibar"
      click_button "Save"
      wait_for_javascript_to_finish
      find("#study_sponsor_name").should have_value("Kurt Zanzibar")
    end
  end

  context "funded fields" do

    before :each do
      select("Funded", from: "Proposal Funding Status")
    end

    describe "editing the funding start date" do

      it "should change and save the date" do
        find("#funding_start_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#funding_start_date").should have_value((Date.today).strftime('%-m/%d/%Y'))
      end
    end

    describe "selecting a funding source" do

      it "should change the indirect cost rate when a source is selected" do
        select("Foundation/Organization", from: "study_funding_source")
        find("#study_indirect_cost_rate").should have_value("25")
        select("Federal", from: "study_funding_source")
        find("#study_indirect_cost_rate").should have_value("49.5")
      end
    end
  end

  context "pending funding fields" do

    before :each do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Federal", from: "study_potential_funding_source")
    end

    describe "editing the funding opportunity number" do

      it "should save the new funding opportunity number" do
        fill_in "study_funding_rfa", with: "12345"
        click_button "Save"
        wait_for_javascript_to_finish
        find("#study_funding_rfa").should have_value("12345")
      end      
    end

    describe "editing the potential funding start date" do

      it "should change and save the date" do
        find("#potential_funding_start_date").click
        wait_for_javascript_to_finish
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        wait_for_javascript_to_finish
        find("#potential_funding_start_date").should have_value((Date.today).strftime('%-m/%d/%Y'))
      end
    end

    describe "selecting a potential funding source" do

      it "should change the indirect cost rate when a source is selected" do
        select("Foundation/Organization", from: "study_potential_funding_source")
        find("#study_indirect_cost_rate").should have_value("25")
      end
    end

    describe "selecting the study phase" do

      it "should change the study phase" do
        select("IV", from: "Study Phase")
        find("#study_study_phase").should have_value("iv")
      end
    end
  end

  context "human subjects" do

    before :each do
      check("study_research_types_info_attributes_human_subjects")
    end

    describe "human subjects checkbox" do

      it "should cause all the human subjects fields to become visible" do
        find("#study_human_subjects_info_attributes_hr_number").should be_visible
      end

      it "should change state when clicked" do
        check("study_research_types_info_attributes_human_subjects")
        find("#study_research_types_info_attributes_human_subjects").should be_checked
      end
    end

    describe "editing the hr number and the pro number" do

      it "should save the new hr and pro number" do
        field_array = ["hr_number", "pro_number"]
        field_num = 0
        2.times do 
          fill_in "study_human_subjects_info_attributes_#{field_array[field_num]}", with: "12345"
          field_num += 1
        end
        click_button "Save"
        wait_for_javascript_to_finish
        find("#study_human_subjects_info_attributes_hr_number").should have_value("12345")
        find("#study_human_subjects_info_attributes_pro_number").should have_value("12345")
      end
    end

    describe "irb of record" do

      it "should save the new irb" do
        fill_in "study_human_subjects_info_attributes_irb_of_record", with: "crazy town"
        click_button "Save"
        wait_for_javascript_to_finish
        find("#study_human_subjects_info_attributes_irb_of_record").should have_value("crazy town")
      end
    end

    describe "selecting the submission type" do

      it "should change the submission type" do
        select("Exempt", from: "Submission Type")
        find("#study_human_subjects_info_attributes_submission_type").should have_value("exempt")
      end
    end

    describe "editing the irb approval date" do

      it "should change and save the date" do
        find("#irb_approval_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_approval_date").should have_value(Date.today.strftime('%-m/%d/%Y'))
      end
    end

    describe "editing the irb expiration date" do

      it "should change and save the date" do
        find("#irb_expiration_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_expiration_date").should have_value(Date.today.strftime('%-m/%d/%Y'))
      end
    end    
  end

  context "research check boxes" do

    describe "vertebrate animals" do

      it "should change their state when clicked" do
        box_array = ["vertebrate_animals", "investigational_products", "ip_patents"]
        box_num = 0
        3.times do
          check("study_research_types_info_attributes_#{box_array[box_num]}")
          box_num += 1
        end
        find("#study_research_types_info_attributes_vertebrate_animals").should be_checked
        find("#study_research_types_info_attributes_investigational_products").should be_checked
        find("#study_research_types_info_attributes_ip_patents").should be_checked
      end
    end
  end  

  context "study check boxes" do

    describe "clinical trials, basic science, and translational science" do

      it "should change their state when clicked" do
        box_num = 0
        3.times do
          check("study_study_types_attributes_#{box_num}__destroy")
          box_num += 1
        end
        find("#study_study_types_attributes_0__destroy").should be_checked
        find("#study_study_types_attributes_1__destroy").should be_checked
        find("#study_study_types_attributes_2__destroy").should be_checked
      end
    end
  end

  context "impact check boxes" do

    describe "pediactrics, hiv/aids, hypertension, stroke, diabetes, cancer, and other" do

      it "should change their state when clicked" do
        box_num = 0
        7.times do
          check("study_impact_areas_attributes_#{box_num}__destroy")
          box_num += 1
        end
        find("#study_impact_areas_attributes_0__destroy").should be_checked
        find("#study_impact_areas_attributes_1__destroy").should be_checked
        find("#study_impact_areas_attributes_2__destroy").should be_checked
        find("#study_impact_areas_attributes_3__destroy").should be_checked
        find("#study_impact_areas_attributes_4__destroy").should be_checked
        find("#study_impact_areas_attributes_5__destroy").should be_checked
        find("#study_impact_areas_attributes_6__destroy").should be_checked
      end

      context "other checkbox" do

        it "should open up text field when 'other' is checked" do
          check("study_impact_areas_attributes_6__destroy")
          find("#study_impact_areas_other").should be_visible 
        end

        it "should save the value after text is entered" do
          check("study_impact_areas_attributes_6__destroy")
          fill_in "study_impact_areas_other", with: "El Guapo's Area"
          click_button "Save"
          wait_for_javascript_to_finish
          find("#study_impact_areas_other").should have_value("El Guapo's Area")
        end
      end
    end
  end

  context "affiliations check boxes" do

    describe "cancer center, lipidomics, oral health, cardiovascular, cchp, inbre, reach" do
      
      it "should change theit state when clicked" do
        box_num = 0
        7.times do
          check("study_affiliations_attributes_#{box_num}__destroy")
          box_num += 1
        end
        find("#study_affiliations_attributes_0__destroy").should be_checked
        find("#study_affiliations_attributes_1__destroy").should be_checked
        find("#study_affiliations_attributes_2__destroy").should be_checked
        find("#study_affiliations_attributes_3__destroy").should be_checked
        find("#study_affiliations_attributes_4__destroy").should be_checked
        find("#study_affiliations_attributes_5__destroy").should be_checked
        find("#study_affiliations_attributes_6__destroy").should be_checked
      end    
    end
  end
end  
