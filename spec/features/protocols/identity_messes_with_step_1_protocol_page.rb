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

RSpec.feature 'User wants to try out features of the Step 1 Protocol page', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  context 'and messes with studies' do
    build_service_request_with_study

    context 'and has a non-submitted Service Request' do
      before :each do
        service_request.update_attribute(:status, 'first_draft')
      end

      context 'and selects the Research Study radio' do
        scenario 'and sees the select box change to Select Study' do
          given_i_am_viewing_the_service_request_protocol_page
          when_i_click_the_radio_of_type "Study"
          then_i_should_see_the_select_box_of_type "Study"
        end

        scenario 'and sees the New button change to New Study' do
          given_i_am_viewing_the_service_request_protocol_page
          when_i_click_the_radio_of_type "Study"
          then_i_should_see_the_the_new_button_of_type "Study"
        end

        context 'and selects a Study from the list' do
          scenario 'and sees the Edit Study button' do
            given_i_am_viewing_the_service_request_protocol_page
            when_i_click_the_radio_of_type "Study"
            when_i_select_a_protocol
            then_i_should_see_the_edit_button_of_type "Study"
          end

          context 'and un-selects and re-selects the Research Study radio' do
            scenario 'and sees the Study is still selected' do
              given_i_am_viewing_the_service_request_protocol_page
              when_i_click_the_radio_of_type "Study"
              when_i_select_a_protocol
              when_i_click_the_radio_of_type "Project"
              when_i_click_the_radio_of_type "Study"
              #TODO: Try and add a check on the option selected by the select box
              then_i_should_see_the_edit_button_of_type "Study"
            end
          end
        end
      end
    end

    context 'and has a submitted Service Request' do
      scenario 'and sees the Study' do
        given_i_am_viewing_the_service_request_protocol_page
        then_i_should_see_the_protocol
      end

      scenario 'and sees the Edit Study button' do
        given_i_am_viewing_the_service_request_protocol_page
        then_i_should_see_the_edit_button_of_type "Study"
      end
    end
  end

  context 'and messes with projects' do
    build_service_request_with_project

    context 'and has a non-submitted Service Request' do
      before :each do
        service_request.update_attribute(:status, 'first_draft')
      end

      context 'and selects the Project radio' do
        scenario 'and sees the select box change to Select Project' do
          given_i_am_viewing_the_service_request_protocol_page
          when_i_click_the_radio_of_type "Project"
          then_i_should_see_the_select_box_of_type "Project"
        end

        scenario 'and sees the New button change to New Study' do
          given_i_am_viewing_the_service_request_protocol_page
          when_i_click_the_radio_of_type "Project"
          then_i_should_see_the_the_new_button_of_type "Project"
        end

        context 'and selects a Project from the list' do
          scenario 'and sees the Edit Project button' do
            given_i_am_viewing_the_service_request_protocol_page
            when_i_click_the_radio_of_type "Project"
            when_i_select_a_protocol
            then_i_should_see_the_edit_button_of_type "Project"
          end

          context 'and un-selects and re-selects the Project radio' do
            scenario 'and sees the Project is still selected' do
              given_i_am_viewing_the_service_request_protocol_page
              when_i_click_the_radio_of_type "Project"
              when_i_select_a_protocol
              when_i_click_the_radio_of_type "Study"
              when_i_click_the_radio_of_type "Project"
              #TODO: Try and add a check on the option selected by the select box
              then_i_should_see_the_edit_button_of_type "Project"
            end
          end
        end
      end
    end

    context 'and has a submitted Service Request' do
      scenario 'and sees the Project' do
        given_i_am_viewing_the_service_request_protocol_page
        then_i_should_see_the_protocol
      end

      scenario 'and sees the Edit Project button' do
        given_i_am_viewing_the_service_request_protocol_page
        then_i_should_see_the_edit_button_of_type "Project"
      end
    end
  end

  def given_i_am_viewing_the_service_request_protocol_page
    visit protocol_service_request_path service_request.id
  end

  def when_i_click_the_radio_of_type protocol_type
    case protocol_type
      when "Study"
        find("input#protocol_Research_Study").click
      when "Project"
        find("input#protocol_Project").click
      else
        puts "An unexpected value was received in when_i_click_the_radio_of_type. Perhaps there was a typo?"
    end
  end

  def when_i_select_a_protocol
    protocol = Protocol.first

    select "#{protocol.id} - #{protocol.short_title}", from: "service_request_protocol_id"
  end

  def then_i_should_see_the_protocol
    protocol = Protocol.first

    expect(page).to have_text("#{protocol.id} - #{protocol.short_title}")
  end

  def then_i_should_see_the_select_box_of_type protocol_type
    case protocol_type
      when "Study"
        expect(page).to have_selector("select.edit_study_id", visible: true)
      when "Project"
        expect(page).to have_selector("select.edit_project_id", visible: true)
      else
        puts "An unexpected value was received in then_i_should_see_the_select_box_of_type. Perhaps there was a typo?"
        expect(0).to eq(1)
    end
  end

  def then_i_should_see_the_the_new_button_of_type protocol_type
    case protocol_type
      when "Study"
        expect(page).to have_selector("a.new-study", text: "New Study", visible: true)
      when "Project"
        expect(page).to have_selector("a.new-project", text:"New Project", visible: true)
      else
        puts "An unexpected value was received in then_i_should_see_the_the_new_button_of_type. Perhaps there was a typo?"
        expect(0).to eq(1)
    end
  end

  def then_i_should_see_the_edit_button_of_type protocol_type
    case protocol_type
      when "Study"
        expect(page).to have_selector(".edit-study", visible: true)
      when "Project"
        expect(page).to have_selector(".edit-project", visible: true)
      else
        puts "An unexpected value was received in then_i_should_see_the_edit_button_of_type. Perhaps there was a typo?"
        expect(0).to eq(1)
    end
  end
end
