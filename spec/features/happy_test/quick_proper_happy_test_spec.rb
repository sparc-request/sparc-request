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
include CapybaraProper

RSpec.describe 'A Quick Happy Test on Sparc Proper', :happy_test do
  let_there_be_lane
  fake_login_for_each_test

  let!(:institution)       {create(:institution,id: 53,name: 'Medical University of South Carolina', order: 1,abbreviation: 'MUSC', is_available: 1) }
  let!(:provider)          {create(:provider,id: 10,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',parent_id: institution.id,abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1) }
  let!(:program)           {create(:program,id:54,type:'Program',name:'Office of Biomedical Informatics',order:1,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:  0,is_available: 1) }
  let!(:program2)          {create(:program,id:5,type:'Program',name:'Clinical and Translational Research Center (CTRC)',order:2,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:0,is_available:1) }
  let!(:core)              {create(:core,id:33,type:'Core',name:'Clinical Data Warehouse',order:1,parent_id:program.id,abbreviation:'Clinical Data Warehouse') }
  let!(:core2)             {create(:core,id:8,type:'Core',name:'Nursing Services',abbreviation:'Nursing Services',order:1,parent_id:program2.id) }
  let!(:service)           {create(:service,id:67,name:'MUSC Research Data Request (CDW)',abbreviation:'CDW',order:1,cpt_code:'',organization_id:core.id, one_time_fee: true) }
  let!(:service2)          {create(:service,id:16,name:'Breast Milk Collection',abbreviation:'Breast Milk Collection',order:1,cpt_code:'',organization_id:core2.id) }
  let!(:pricing_setup)     { create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal') }
  let!(:pricing_setup2)    { create(:pricing_setup, organization_id: program2.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal') }
  let!(:pricing_map)       {create(:pricing_map,service_id:service.id, unit_type: 'Per Query', unit_factor: 1, display_date: Time.now - 1.day, full_rate: 200, exclude_from_indirect_cost: 0, unit_minimum:1) }
  let!(:pricing_map2)      {create(:pricing_map, service_id: service2.id, unit_type: 'Per patient/visit', unit_factor: 1, display_date: Time.now - 1.day, full_rate: 636, exclude_from_indirect_cost: 0, unit_minimum: 1) }
  let!(:service_provider)  { create(:service_provider, organization_id: program.id, identity_id: jug2.id) }
  let!(:service_provider2) { create(:service_provider, organization_id: program2.id, identity_id: jug2.id) }

  before(:each) do
    StudyTypeQuestion.create("order"=>1, "question"=>"1a. Does your study require a higher level of privacy for the participants?", "friendly_id"=>"higher_level_of_privacy")
    StudyTypeQuestion.create("order"=>2, "question"=>"1b. Does your study have a Certificate of Confidentiality?", "friendly_id"=>"certificate_of_conf")
    StudyTypeQuestion.create("order"=>3, "question"=>"1c. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?", "friendly_id"=>"access_study_info")
    StudyTypeQuestion.create("order"=>4, "question"=>"2. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?", "friendly_id"=>"epic_inbasket")
    StudyTypeQuestion.create("order"=>5, "question"=>"3. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?", "friendly_id"=>"research_active")
    StudyTypeQuestion.create("order"=>6, "question"=>"4. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?", "friendly_id"=>"restrict_sending")
  end

  it 'should properly make you happy in a quick manner', js: true do
    visit root_path

    #**Submit a service request**#
    wait_for_javascript_to_finish
    addService 'CDW'
    addService 'Breast Milk Collection'
    find('.submit-request-button').click
    wait_for_javascript_to_finish
    #**END Submit a service request END**#

    #**Create a new Study**#
    click_link("New Study")
    wait_for_javascript_to_finish
    find('#study_has_cofc_true').click
    fill_in "study_short_title", with: "Bob"
    fill_in "study_title", with: "Dole"
    fill_in "study_sponsor_name", with: "Captain Kurt 'Hotdog' Zanzibar"
    select "Funded", from: "study_funding_status"
    select "Federal", from: "study_funding_source"
    clickContinueButton
    #**END Create a new Study END**#

    #**Select Users**#
    expect(page).to have_css('#project_role_role')

    select "Primary PI", from: "project_role_role"
    click_button "Add Authorized User"
    fill_autocomplete('user_search_term', with: 'bjk7')
    page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
    wait_for_javascript_to_finish
    select "Billing/Business Manager", from: "project_role_role"
    click_button "Add Authorized User"

    #test edit epic rights here
    # editEpicUserAccess
    #end test epic rights

    clickContinueButton
    saveAndContinue
    #**END Select Users END**#

    #**Select Dates and Arms**#
        #Select Start and End Date**
    strtDay = Time.now.strftime("%-d")# Today's Day
    endDay = (Time.now + 7.days).strftime("%-d")# 7 days from today
    page.execute_script %Q{ $('#start_date').trigger("focus") }
    page.execute_script %Q{ $("a.ui-state-default:contains('#{strtDay}')").filter(function(){return $(this).text()==='#{strtDay}';}).trigger("click") } # click on start day
    wait_for_javascript_to_finish
    page.execute_script %Q{ $('#end_date').trigger("focus") }
    if endDay.to_i < strtDay.to_i then
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # move one month forward
      wait_for_javascript_to_finish
    end
    page.execute_script %Q{ $("a.ui-state-default:contains('#{endDay}')").filter(function(){return $(this).text()==='#{endDay}';}).trigger("click") } # click on end day
    wait_for_javascript_to_finish

        #Add Arm 1**
    fill_in "study_arms_attributes_0_name", with: "ARM 1"
    fill_in "study_arms_attributes_0_subject_count", with: "5" # 5 subjects
    fill_in "study_arms_attributes_0_visit_count", with: "8" # 8 visit
    wait_for_javascript_to_finish
    saveAndContinue
    #**END Select Dates and Arms END**#

    #**Completing Visit Calender**#
    wait_for_javascript_to_finish
    setVisitDays('ARM 1',8) #set days in increasing order
    check('visits_2') #Check 1st visit
    select 'Visits 6 - 8 of 8', from: 'jump_to_visit_1'
    check('visits_7') #Check 2nd visit
    check('visits_8') #Check 3rd visit
    first(:xpath, "//input[@class='line_item_quantity']").set("3") #set CDW quantity to 3
    saveAndContinue
    #**END Completing Visit Calender END**#

    #**Documents page**#
    documentsPage
    #**END Documents page END**#

    #**Review Page**#
    click_link("Submit to Start Services")
    wait_for_javascript_to_finish
    if have_xpath("//div[@aria-describedby='participate_in_survey' and @display!='none']") then
        first(:xpath, "//button/span[text()='No']").click
        wait_for_javascript_to_finish
    end
    #**END Review Page END**#

    #**Submission Confirmation Page**#
    submissionConfirmationPage
    #**END Submission Confirmation Page END**#
  end
end
