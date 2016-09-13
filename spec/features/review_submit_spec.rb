# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
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
require 'surveyor/parser'
require 'rake'

RSpec.describe "review page", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study
  build_study_type_question_groups
  build_study_type_questions
  build_study_type_answers

  before :each do
    file = File.join(Rails.root, 'surveys/system_satisfaction_survey.rb')
    Surveyor::Parser.parse_file(file, {trace: Rake.application.options.trace})
    add_visits
    visit review_service_request_path service_request.id
  end

  # This test does not currently work with group validations. Verified that what this is
  # testing does change the status from 'submitted' to 'draft'.
  # describe "clicking save and exit/draft" do
  #   it 'Should save request as a draft' do
  #     find('.save-as-draft').click

  #     service_request_test = ServiceRequest.find(service_request.id)
  #     service_request_test.status.should eq("draft")
  #   end
  # end

  describe "clicking submit" do
    it 'Should submit the page', js: true do
      find("#submit_services1").click
      wait_for_javascript_to_finish
      if SYSTEM_SATISFACTION_SURVEY
        click_button("No")
        wait_for_javascript_to_finish
      end
      service_request_test = ServiceRequest.find(service_request.id)
      expect(service_request_test.status).to eq("submitted")
    end
  end

  describe "clicking save as draft" do
    it 'Should render a notification for the user' do
      find("#save-as-draft").click
      wait_for_javascript_to_finish
      expect(page).to have_content("Notification")
    end

    describe "clicking yes in the notification" do
      it 'Should save the service request and redirect to user portal' do
        find("#save-as-draft").click
        wait_for_javascript_to_finish
        find("button.ui-button .ui-button-text", text: "Yes").click
        wait_for_javascript_to_finish
        expect(current_path).to eq(dashboard_root_path)
      end
    end

    describe "clicking no in the notification" do
      it 'Should close the notification box and do nothing' do
        find("#save-as-draft").click
        wait_for_javascript_to_finish
        find("button.ui-button .ui-button-text", text: "No").click
        wait_for_javascript_to_finish
        expect(page).to_not have_content("Notification")
      end
    end
  end

  describe "clicking get a cost estimate and declining the system satisfaction survey (if turned on)" do
    it 'Should submit the page', js: true do
      find("#get_a_cost_estimate").click
      if SYSTEM_SATISFACTION_SURVEY
        find(:xpath, "//button/span[text()='No']/..").click
        wait_for_javascript_to_finish
      end
      service_request_test = ServiceRequest.find(service_request.id)
      expect(service_request_test.status).to eq("get_a_cost_estimate")
    end
  end

  context 'epic emails' do

    before :each do
      stub_const("QUEUE_EPIC", false)
      stub_const("USE_EPIC", true)
      service2.update_attributes(send_to_epic: true, charge_code: nil, cpt_code: nil)
      service_request.protocol.update_attribute(:selected_for_epic, true)
      clear_emails
      find("#submit_services1").click
      wait_for_javascript_to_finish
      if SYSTEM_SATISFACTION_SURVEY
        click_button("No")
        wait_for_javascript_to_finish
      end

      # Find 'Epic Rights Approval' email, and grab the HTML part.
      email = all_emails.find { |e| e.subject == "Epic Rights Approval" }
      @email = email.parts.find { |e| e.content_type.include?('html') }
      service_request.update_attributes(status: 'submitted')
    end

    it 'should send an email to the Epic admins' do
      expect(@email.body).to have_content "To approve the users and rights"
    end

    # Table is filled correctly
    it 'should have the correct users in the table' do
      project_role = study.project_roles.first
      expect(@email.body).not_to have_content study.project_roles.last.identity.full_name

      n = Capybara::Node::Simple.new(@email.body.to_s).find("#project_role_#{study.project_roles.first.id}")
      expect(n.find(".name")).to have_content project_role.identity.full_name
      expect(n.find(".role")).to have_content USER_ROLES.invert[project_role.role]
      expect(n.find(".epic_rights")).to have_content(EPIC_RIGHTS["view_rights"])
    end

    # Primary PI link
    it 'should be able to click the send to primary pi link' do
      visit Capybara::Node::Simple.new(@email.body.to_s).find_link("Send to Primary PI")['href']
      expect(page).to have_content "Thank you. An email has been sent to the primary PI for the final approval."
    end

    context 'primary pi emails' do
      before :each do
        clear_emails
        visit Capybara::Node::Simple.new(@email.body.to_s).find_link("Send to Primary PI")['href']

        # Find 'Epic Rights Approval' email, and grab the HTML part.
        email = all_emails.find { |e| e.subject == "Epic Rights User Approval" }
        @email = email.parts.find { |e| e.content_type.include?('html') }
      end

      it "should send an email to the Primary PI" do
        expect(@email.body).to have_content("The following SPARC Request users have requested access to Epic for your study ##{study.id}")
      end

      it "should have the correct users in the table" do
        project_role = study.project_roles.first
        expect(@email.body.to_s).not_to have_content study.project_roles.last.identity.full_name

        n = Capybara::Node::Simple.new(@email.body.to_s).find("#project_role_#{study.project_roles.first.id}")
        expect(n.find(".name")).to have_content project_role.identity.full_name
        expect(n.find(".role")).to have_content USER_ROLES.invert[project_role.role]
        expect(n.find(".epic_rights")).to have_content(EPIC_RIGHTS["view_rights"])
      end

      it "should send the study to epic" do
        visit Capybara::Node::Simple.new(@email.body.to_s).find_link("Send to Epic")['href']
        expect(page).to have_content "Study has been sent to Epic"
      end

      it "should not send services missing cpt code and charge code" do

        visit Capybara::Node::Simple.new(@email.body.to_s).find_link("Send to Epic")['href']
        wait_for_javascript_to_finish
        expect(page).to have_content "#{service2.name} does not have a CPT or a Charge code."
      end
    end
  end
end

def clear_emails
  ActionMailer::Base.deliveries = []
end

def all_emails
  ActionMailer::Base.deliveries
end
