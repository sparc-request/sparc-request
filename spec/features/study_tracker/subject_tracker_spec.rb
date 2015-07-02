# coding: utf-8
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

RSpec.describe "Subject Tracker", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits
    build_clinical_data(all_subjects = true)
    sub_service_request.update_attributes(in_work_fulfillment: true)
    visit study_tracker_sub_service_request_path sub_service_request.id
    click_link("Subject Tracker")
    wait_for_javascript_to_finish
  end

  describe "viewing subjects" do
    it "should show pre-created subject in each arm" do
      expect(page).to have_css("input#subject_#{arm1.subjects.first.id}_name")
      expect(page).to have_css("input#subject_#{arm2.subjects.first.id}_name")
    end
  end

  describe "editing a subject" do
    it "should allow you to edit an existing subject" do
      fill_in "subject_#{arm1.subjects.first.id}_name", with: "Disco Stu"
      fill_in "subject_#{arm1.subjects.first.id}_mrn", with: "1234"
      fill_in "subject_#{arm1.subjects.first.id}_id", with: "5678"
      ##fill_in "subject_#{arm1.subjects.first.id}_dob", with: "2013-06-20"
      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      expect(arm1.subjects.first.name).to eq("Disco Stu")
      expect(arm1.subjects.first.mrn).to eq("1234")
      expect(arm1.subjects.first.external_subject_id).to eq("5678")
      ##arm1.subjects.first.dob.to_s.should eq("2013-06-20")
    end
  end

  describe "adding a subject" do
    it "should allow you to add a subject to a specific arm" do
      subject_count = arm2.subject_count
      subjects_count = arm2.subjects.count

      within("div#arm_#{arm2.id}") do
        click_link("Add a subject")
      end

      fill_in "subject__name", with: "Disco Sue"
      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      arm2.reload
      expect(arm2.subject_count).to eq(subject_count + 1)
      expect(arm2.subjects.count).to eq(subjects_count + 1)
      expect(arm2.subjects.last.name).to eq("Disco Sue")
    end
  end

  describe "deleting a subject" do

    it "should allow you to delete a subject" do
      subject_count = arm2.subject_count
      subjects_count = arm2.subjects.count

      accept_alert("Are you sure you want to delete this subject?") do
        within("tr.subject_id_#{arm2.subjects.last.id}") do
          click_link("Delete")
        end
      end

      within("div#subject_tracker") do
        click_button("Save")
      end

      wait_for_javascript_to_finish
      arm2.reload
      expect(arm2.subject_count).to eq(subject_count - 1)
      expect(arm2.subjects.count).to eq(subjects_count - 1)
    end

    # setting in_work_fulfillment to true at the model level isn't populating
    # arms with subjects; see failing models/sub_service_request/sub_service_request_spec.rb
    it "should not delete a subject if that subject has any completed appointments" do
      subject_count = arm1.subjects.count
      subject       = arm1.subjects.first
      appointment   = create(:appointment, calendar_id: subject.calendar.id, completed_at: Date.today - 1)

      within("div#subject_tracker") do
        click_button("Save")
      end

      accept_alert("This subject has one or more completed appointments and can't be deleted.") do
        within("tr.subject_id_#{arm1.subjects.first.id}") do
          find(".cwf_subject_delete").click
        end
      end

      wait_for_javascript_to_finish
      expect(subject_count).to eq(arm1.subjects.count)
    end
  end
end
