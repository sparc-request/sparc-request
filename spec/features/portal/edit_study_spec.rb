require 'spec_helper'

describe "editing a study", js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_study()
  let(:numerical_day) { Date.today.strftime("%d").gsub(/^0/,'') }

  before :each do
    visit edit_portal_protocol_path service_request.id
  end

  context "validations" do

    it "should raise an error message if study's status is pending and no potential funding source is selected" do
      select("Pending Funding", from: "Proposal Funding Status")
      click_button "Save study"
      page.should have_content("1 error prohibited this study from being saved")
    end

    it "should raise an error message if study's status is funded but no funding source is selected" do
      select("Funded", from: "Proposal Funding Status")
      select("Select a Funding Source", from: "study_funding_source")
      click_button "Save study"
      page.should have_content("1 error prohibited this study from being saved")
    end
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

    it "should change to pending funding" do
      select("Pending Funding", from: "Proposal Funding Status")
      find("#study_funding_status").value().should eq("pending_funding")
    end

    it "should change to funded" do
      select("Funded", from: "Proposal Funding Status")
      find("#study_funding_status").value().should eq("funded")
    end
  end

  context "editing the UDAK/Project #" do

    it "should save the udak/project number" do
      fill_in "study_udak_project_number", with: "12345"
      click_button "Save study"
      visit edit_portal_protocol_path service_request.id
      find("#study_udak_project_number").value().should eq("12345")
    end    
  end

  context "editing the sponsor name" do

    it "should save the sponsor name" do
      fill_in "study_sponsor_name", with: "Kurt Zanzibar"
      click_button "Save study"
      visit edit_portal_protocol_path service_request.id
      find("#study_sponsor_name").value().should eq("Kurt Zanzibar")
    end
  end

  context "funded fields" do

    before :each do
      select("Funded", from: "Proposal Funding Status")
    end

    describe "editing the funding start date" do

      it "should change and save the date" do
        find("#funding_start_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
        find("#funding_start_date").value().should eq(Date.today.strftime('%-m/%d/%Y'))
      end
    end

    describe "selecting a funding source" do

      it "should change the indirect cost rate when a source is selected" do
        select("Foundation/Organization", from: "study_funding_source")
        find("#study_indirect_cost_rate").value().should eq("25")
        select("Federal", from: "study_funding_source")
        find("#study_indirect_cost_rate").value().should eq("47.5")
      end
    end
  end

  context "pending funding fields" do

    before :each do
      select("Pending Funding", from: "Proposal Funding Status")
      select("Federal", from: "study_potential_funding_source")
    end

    describe "editing the funding opportunity number" do

      it "should save the funding opportunity number" do
        fill_in "study_funding_rfa", with: "12345"
        click_button "Save study"
        visit edit_portal_protocol_path service_request.id
        find("#study_funding_rfa").value().should eq("12345")
      end      
    end

    describe "editing the potential funding start date" do

      it "should change and save the date" do
        find("#potential_funding_start_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#potential_funding_start_date").value().should eq(Date.today.strftime('%-m/%d/%Y'))
      end
    end

    describe "selecting a potential funding source" do

      it "should change the indirect cost rate when a source is selected" do
        select("Foundation/Organization", from: "study_potential_funding_source")
        find("#study_indirect_cost_rate").value().should eq("25")
      end
    end

    describe "selecting the study phase" do

      it "should change the study phase" do
        select("IV", from: "Study Phase")
        find("#study_study_phase").value().should eq("iv")
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

    describe "editing the hr number" do

      it "should save the hr number" do
        fill_in "study_human_subjects_info_attributes_hr_number", with: "12345"
        click_button "Save study"
        visit edit_portal_protocol_path service_request.id
        find("#study_human_subjects_info_attributes_hr_number").value().should eq("12345")
      end
    end

    describe "editing the pro number" do

      it "should save the pro number" do
        fill_in "study_human_subjects_info_attributes_pro_number", with: "12345"
        click_button "Save study"
        visit edit_portal_protocol_path service_request.id
        find("#study_human_subjects_info_attributes_pro_number").value().should eq("12345")
      end
    end

    describe "irb of record" do

      it "should save the irb" do
        fill_in "study_human_subjects_info_attributes_irb_of_record", with: "crazy town"
        click_button "Save study"
        visit edit_portal_protocol_path service_request.id
        find("#study_human_subjects_info_attributes_irb_of_record").value().should eq("crazy town")
      end
    end

    describe "selecting the submission type" do

      it "should change the submission type" do
        select("Exempt", from: "Submission Type")
        find("#study_human_subjects_info_attributes_submission_type").value().should eq("exempt")
      end
    end

    describe "editing the irb approval date" do

      it "should change and save the date" do
        find("#irb_approval_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_approval_date").value().should eq(Date.today.strftime('%-m/%d/%Y'))
      end
    end

    describe "editing the irb expiration date" do

      it "should change and save the date" do
        find("#irb_expiration_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_expiration_date").value().should eq(Date.today.strftime('%-m/%d/%Y'))
      end
    end    
  end

  context "research check boxes" do

    describe "vertebrate animals" do

      it "should change state when clicked" do
        check("study_research_types_info_attributes_vertebrate_animals")
        find("#study_research_types_info_attributes_vertebrate_animals").should be_checked
      end
    end

    describe "investigational products" do

      it "should change state when clicked" do
        check("study_research_types_info_attributes_investigational_products")
        find("#study_research_types_info_attributes_investigational_products").should be_checked
      end
    end

    describe "ip/patents" do

      it "should change state when clicked" do
        check("study_research_types_info_attributes_ip_patents")
        find("#study_research_types_info_attributes_ip_patents").should be_checked
      end
    end
  end  
end