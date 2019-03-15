# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe "User submitting a ServiceRequest", js: true do
  def click_add_service_for(service)
    page.find("button[data-id='#{service.id}']").click
    wait_for_javascript_to_finish
  end

  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  stub_config("system_satisfaction_survey", true)
  
  it "is happy" do
    allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)

    #######################################
    # Organization structure and Services #
    #######################################
    institution         = create(:organization, type: 'Institution', name: 'Institution', abbreviation: 'Instant')

    provider_non_split  = create(:organization, :with_pricing_setup, type: 'Provider', name: 'Provider Non Split', abbreviation: 'Prov No Splt', parent: institution)
    provider_split      = create(:organization, :with_pricing_setup, type: 'Provider', name: 'Provider Split', abbreviation: 'Prov Splt', process_ssrs: true, parent: institution)

    program_non_split   = create(:organization, type: 'Program', name: 'Program Non Split', abbreviation: 'Prog No Splt', parent: provider_split)
    program_split       = create(:organization, type: 'Program', name: 'Program Split', abbreviation: 'Prog Splt', process_ssrs: true, parent: provider_non_split)

    core1               = create(:organization, type: 'Core', name: 'Core 1', abbreviation: 'Core1', parent: program_split)
    core2               = create(:organization, type: 'Core', name: 'Core 2', abbreviation: 'Core2', parent: program_non_split)

    otf_service_core_1  = create(:one_time_fee_service, :with_pricing_map, name: 'Otf Service Core 1', abbreviation: 'Otf Serv Core1', organization: core1)
    pppv_service_core_1 = create(:per_patient_per_visit_service, :with_pricing_map, name: 'PPPV Service Core 1', abbreviation: 'PPPV Serv Core1', organization: core1)
    otf_service_core_2  = create(:one_time_fee_service, :with_pricing_map, name: 'Otf Service Core 2', abbreviation: 'Otf Serv Core2', organization: core2)
    pppv_service_core_2 = create(:per_patient_per_visit_service, :with_pricing_map, name: 'PPPV Service Core 1', abbreviation: 'PPPV Serv Core1', organization: core2)



    ####################
    # Survey structure #
    ####################
    survey      = create(:system_survey, :active, title: 'System Satisfaction Survey', access_code: 'system-satisfaction-survey', active: true)
    section     = create(:section, survey: survey)
    question_1  = create(:question, question_type: 'likert', content: '1) How satisfied are you with using SPARCRequest today?', section: section)
    option_1    = create(:option, content: 'Very Dissatisfied', question: question_1)
    option_2    = create(:option, content: 'Dissatisfied', question: question_1)
    option_3    = create(:option, content: 'Neutral', question: question_1)
    option_4    = create(:option, content: 'Satisfied', question: question_1)
    option_5    = create(:option, content: 'Very Satisfied', question: question_1)
    question_2  = create(:question, question_type: 'textarea', content: '2) Please leave your feedback and/or suggestions for future improvement.', section: section)



    ##########
    # Step 1 #
    ##########
    visit root_path
    wait_for_javascript_to_finish

    expect(page).to have_selector('.step-header', text: 'STEP 1')



    ##########
    # Log in #
    ##########
    click_link 'Login / Sign Up'
    wait_for_javascript_to_finish

    expect(page).to have_selector("a", text: /Outside User Login/)
    find("a", text: /Outside User Login/).click
    wait_for_javascript_to_finish

    fill_in "Login", with: "johnd"
    fill_in "Password", with: "p4ssword"
    click_button 'Login'
    wait_for_javascript_to_finish



    #######################
    # Add Core 1 Services #
    #######################
    expect(page).to have_selector("span", text: provider_non_split.name)

    find("span", text: provider_non_split.name).click
    wait_for_javascript_to_finish

    find("span", text: program_split.name).click
    wait_for_javascript_to_finish

    find("span", text: core1.name).click
    wait_for_javascript_to_finish

    expect(page).to have_selector('.core-accordion .service', text: otf_service_core_1.name, visible: true)
    expect(page).to have_selector('.core-accordion .service', text: pppv_service_core_1.name, visible: true)

    click_add_service_for(otf_service_core_1)
    find("a", text: /Yes/).click
    wait_for_javascript_to_finish

    within(".shopping-cart") do
      expect(page).to have_selector('.service', text: otf_service_core_1.abbreviation, visible: true)
    end

    click_add_service_for(pppv_service_core_1)

    within(".shopping-cart") do
      expect(page).to have_selector('.service', text: pppv_service_core_1.abbreviation, visible: true)
    end



    #######################
    # Add Core 2 Services #
    #######################
    expect(page).to have_selector("span", text: provider_split.name)

    find("span", text: provider_split.name).click
    wait_for_javascript_to_finish

    find("span", text: program_non_split.name).click
    wait_for_javascript_to_finish

    find("span", text: core2.name).click
    wait_for_javascript_to_finish

    expect(page).to have_selector('.core-accordion .service', text: otf_service_core_2.name, visible: true)
    expect(page).to have_selector('.core-accordion .service', text: pppv_service_core_2.name, visible: true)

    click_add_service_for(otf_service_core_2)

    within(".shopping-cart") do
      expect(page).to have_selector('.service', text: otf_service_core_2.abbreviation, visible: true)
    end

    click_add_service_for(pppv_service_core_2)

    within(".shopping-cart") do
      expect(page).to have_selector('.service', text: pppv_service_core_2.abbreviation, visible: true)
    end

    click_link 'Continue'
    wait_for_javascript_to_finish



    ##########
    # Step 2 #
    ##########
    expect(page).to have_selector('.step-header', text: 'STEP 2')

    click_link("New Project")
    wait_for_javascript_to_finish

    fill_in("Short Title:", with: "My Protocol")
    fill_in("Project Title:", with: "My Protocol is Very Important - #12345")

    click_button("Select a Funding Status")
    find("li", text: "Funded").click
    expect(page).to have_button("Select a Funding Source")
    click_button("Select a Funding Source")
    find("li", text: "Federal").click

    fill_in "Primary PI:", with: "john"

    expect(page).to have_selector("div.tt-selectable", text: /johnd@musc.edu/)
    first("div.tt-selectable", text: /johnd@musc.edu/).click
    wait_for_javascript_to_finish

    click_button 'Save'
    wait_for_page(protocol_service_request_path)

    click_link 'Save and Continue'
    wait_for_javascript_to_finish



    ##########
    # Step 3 #
    ##########
    expect(page).to have_selector('.step-header', text: 'STEP 3')
    
    find('#project_start_date').click
    within(".bootstrap-datetimepicker-widget") do
      first("td.day", text: "1").click
    end

    find('#project_end_date').click
    within(".bootstrap-datetimepicker-widget") do
      first("td.day", text: "1").click
    end

    click_link 'Save and Continue'
    wait_for_javascript_to_finish



    ##########
    # Step 4 #
    ##########
    expect(page).to have_selector('.step-header', text: 'STEP 4')
    
    find("a", text: "(?)").click
    wait_for_javascript_to_finish

    fill_in 'visit_group_day', with: 1

    click_button 'Save changes'
    wait_for_javascript_to_finish

    click_link 'Save and Continue'
    wait_for_javascript_to_finish



    ##########
    # Step 5 #
    ##########
    expect(page).to have_selector('.step-header', text: 'STEP 5')

    click_link 'Save and Continue'
    wait_for_javascript_to_finish



    ##########
    # Step 6 #
    ##########
    expect(page).to have_selector('.step-header', text: 'STEP 6')

    click_link 'Submit Request'
    wait_for_javascript_to_finish



    ##########
    # Survey #
    ##########
    within '.modal-dialog' do
      find('.yes-button').click
      wait_for_javascript_to_finish

      find('#response_question_responses_attributes_0_content_very_satisfied').click
      fill_in 'response_question_responses_attributes_1_content', with: 'I\'m so happy!'

      click_button 'Submit'
      wait_for_javascript_to_finish
    end



    ##########
    # Step 5 #
    ##########
    expect(page).to have_selector('.step-header', text: 'Confirmation')

    click_link 'Go to Dashboard'
    wait_for_javascript_to_finish



    #############
    # Dashboard #
    #############
    expect(page).to have_content("My Protocol")
  end
end
