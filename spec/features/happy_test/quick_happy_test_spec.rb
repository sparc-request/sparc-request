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
include CapybaraCatalogManager
include CapybaraProper
include CapybaraAdminPortal 
include CapybaraClinical 
include CapybaraUserPortal

describe 'A Quick Happy Test' do
  let_there_be_lane
  fake_login_for_each_test

  it 'should make you feel happy quickly', :js => true do
    createTags
    visit catalog_manager_root_path

    create_new_institution 'Medical University of South Carolina', {:abbreviation => 'MUSC'}
    create_new_provider 'South Carolina Clinical and Translational Institute (SCTR)', 'Medical University of South Carolina', {:abbreviation => 'SCTR1'}
    create_new_program 'Office of Biomedical Informatics', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_program 'Clinical and Translational Research Center (CTRC)', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics', :process_ssrs => true, :tags => ['Clinical work fulfillment', 'Nexus']}
    create_new_core 'Clinical Data Warehouse', 'Office of Biomedical Informatics'
    create_new_core 'Nursing Services', 'Clinical and Translational Research Center (CTRC)', :tags => ['Clinical work fulfillment']
    create_new_service 'MUSC Research Data Request (CDW)', 'Clinical Data Warehouse', {:otf => true, :unit_type => 'Per Query', :unit_factor => 1, :rate => '2.00', :unit_minimum => 1}
    create_new_service 'Breast Milk Collection', 'Nursing Services', {:otf => false, :unit_type => 'Per patient/visit', :unit_factor => 1, :rate => '6.36', :unit_minimum => 1}

    visit root_path

    #**Submit a service request**#
    addService 'CDW'
    addService 'Breast Milk Collection'
    find('.submit-request-button').click
    wait_for_javascript_to_finish
    #**END Submit a service request END**#
    
    #**Create a new Study**#
    click_link("New Study")
    wait_for_javascript_to_finish
    fill_in "study_short_title", :with => "Bob"
    fill_in "study_title", :with => "Dole"
    fill_in "study_sponsor_name", :with => "Captain Kurt 'Hotdog' Zanzibar"
    select "Funded", :from => "study_funding_status"
    select "Federal", :from => "study_funding_source"
    clickContinueButton
    #**END Create a new Study END**#

    #**Select Users**#
    select "Primary PI", :from => "project_role_role"
    click_button "Add Authorized User"
    wait_for_javascript_to_finish
    fill_in "user_search_term", :with => "bjk7"
    wait_for_javascript_to_finish
    page.find('a', :text => "Brian Kelsey (kelsey@musc.edu)", :visible => true).click()
    wait_for_javascript_to_finish
    select "Billing/Business Manager", :from => "project_role_role"
    click_button "Add Authorized User"
    wait_for_javascript_to_finish
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
    fill_in "study_arms_attributes_0_subject_count", :with => "5" # 5 subjects
    fill_in "study_arms_attributes_0_visit_count", :with => "5" # 5 visit
    wait_for_javascript_to_finish
    saveAndContinue
    #**END Select Dates and Arms END**#

    #**Completing Visit Calender**#
    setVisitDays('ARM 1',5) #set days in increasing order
    check('visits_2') #Check 1st visit
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
    
    #**Admin Portal**#
    goToAdminPortal
    enterServiceRequest('Bob', 'Breast Milk Collection')
    checkTabsAP
    wait_for_javascript_to_finish
    sendToCWF 
    #**END Admin Portal END**#

    #**CWF**#
    goToCWF
    enterServiceRequest('Bob', 'Breast Milk Collection')
    checkTabsCWF
    #**END CWF END**#

    #**User Portal**#
    goToUserPortal
    createNewRequestTest
    findStudy('Bob')
    authorizedUsersTest("bjk7", "Brian Kelsey")
    #**END User Portal END**#

  end

end
