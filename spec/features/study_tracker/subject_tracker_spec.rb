require 'spec_helper'

describe "Subject Tracker", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits
    build_clinical_data(all_subjects = true)
    sub_service_request.update_attributes(:in_work_fulfillment => true)
    visit study_tracker_sub_service_request_path sub_service_request.id
    click_link("Subject Tracker")
    wait_for_javascript_to_finish
  end

  describe "viewing subjects" do
    it "should show pre-created subject in each arm" do
      page.should have_css("input#subject_#{arm1.subjects.first.id}_name")
      page.should have_css("input#subject_#{arm2.subjects.first.id}_name")
    end
  end

  describe "editing a subject" do
    it "should allow you to edit an existing subject" do
      fill_in "subject_#{arm1.subjects.first.id}_name", :with => "Disco Stu"
      fill_in "subject_#{arm1.subjects.first.id}_mrn", :with => "1234"
      fill_in "subject_#{arm1.subjects.first.id}_id", :with => "5678"
      fill_in "subject_#{arm1.subjects.first.id}_dob", :with => "2013-06-20"
      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      arm1.subjects.first.name.should eq("Disco Stu")
      arm1.subjects.first.mrn.should eq("1234")
      arm1.subjects.first.external_subject_id.should eq("5678")
      arm1.subjects.first.dob.to_s.should eq("2013-06-20")
    end
  end

  describe "adding a subject" do
    it "should allow you to add a subject to a specific arm" do
      subject_count = arm2.subject_count
      subjects_count = arm2.subjects.count

      within("div#arm_#{arm2.id}") do
        click_link("Add a subject")
      end

      fill_in "subject__name", :with => "Disco Sue"
      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      arm2.reload
      arm2.subject_count.should eq(subject_count + 1)
      arm2.subjects.count.should eq(subjects_count + 1)
      arm2.subjects.last.name.should eq("Disco Sue")
    end
  end

  describe "deleting a subject" do
    it "should allow you to delete a subject" do
      subject_count = arm2.subject_count
      subjects_count = arm2.subjects.count

      within("tr.subject_id_#{arm2.subjects.last.id}") do
        click_link("Delete")
      end

      a = page.driver.browser.switch_to.alert
      a.text.should eq "Are you sure you want to delete this subject?"
      a.accept

      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      arm2.reload
      arm2.subject_count.should eq(subject_count - 1)
      arm2.subjects.count.should eq(subjects_count - 1)
    end
  end
end