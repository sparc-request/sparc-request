require 'spec_helper'
include CapybaraCatalogManager

describe 'A Happy Test' do
  let_there_be_lane
  fake_login_for_each_test

  it 'should make you feel happy', :js => true do
    visit catalog_manager_root_path
    create_new_institution 'Medical University of South Carolina', {:abbreviation => 'MUSC'}
    create_new_provider 'South Carolina Clinical and Translational Institute (SCTR)', 'Medical University of South Carolina', {:abbreviation => 'SCTR1'}
    create_new_program 'Office of Biomedical Informatics', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_program 'Clinical and Translational Research Center (CTRC)', 'South Carolina Clinical and Translational Institute (SCTR)', {:abbreviation => 'Informatics'}
    create_new_core 'Clinical Data Warehouse', 'Office of Biomedical Informatics'
    create_new_core 'Nursing Services', 'Clinical and Translational Research Center (CTRC)'
    create_new_service 'MUSC Research Data Request (CDW)', 'Clinical Data Warehouse', {:otf => true, :unit_type => 'Per Query', :unit_factor => 1, :rate => '2.00', :unit_minimum => 1}
    create_new_service 'Breast Milk Collection', 'Nursing Services', {:otf => false, :unit_type => 'Per patient/visit', :unit_factor => 1, :rate => '6.36', :unit_minimum => 1}

    visit root_path

    #**Submit a service request**#
    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")

    click_link("Office of Biomedical Informatics")
    wait_for_javascript_to_finish
    click_button("Add")
    wait_for_javascript_to_finish

    click_link("Clinical and Translational Research Center (CTRC)")
    wait_for_javascript_to_finish
    click_button("Add")
    wait_for_javascript_to_finish

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

    find('.continue_button').click
    wait_for_javascript_to_finish
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

    find('.continue_button').click
    wait_for_javascript_to_finish

    click_link("Save & Continue")
    wait_for_javascript_to_finish
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
    #Select Start and End Date**END

    #Select Recruitment Start and End Date**
    #Select Recruitment Start and End Date**END

    #Add Arm 1**
    fill_in "study_arms_attributes_0_subject_count", :with => "5" # 5 subjects
    fill_in "study_arms_attributes_0_visit_count", :with => "5" # 5 visit
    wait_for_javascript_to_finish
    #Add Arm 1**END

    click_link("Save & Continue")
    wait_for_javascript_to_finish
    #**END Select Dates and Arms END**#

    #**Completing Visit Calender**#
      #set days in increasing order**
    first(:xpath, "//input[@id='day' and @class='visit_day position_1']").set("1")
    first(:xpath, "//input[@id='day' and @class='visit_day position_2']").set("2")
    first(:xpath, "//input[@id='day' and @class='visit_day position_3']").set("3")
    first(:xpath, "//input[@id='day' and @class='visit_day position_4']").set("4")
    first(:xpath, "//input[@id='day' and @class='visit_day position_5']").set("5")
      #set days in increasing order**END
    #sleep 30
    check('visits_2') #Check 1st visit
    check('visits_7') #Check 2nd visit
    check('visits_8') #Check 3rd visit

    first(:xpath, "//input[@class='line_item_quantity']").set("3") #set CDW quantity to 3
    click_link("Save & Continue")
    wait_for_javascript_to_finish
    #**END Completing Visit Calender END**#

    #**Documents page**#
    #click_link("Add a New Document")
    #all('process_ssr_organization_ids_').each {|a| check(a)}
    #select "Other", :from => "doc_type"
    click_link("Save & Continue")
    wait_for_javascript_to_finish
    #**END Documents page END**#

    #**Review Page**#
    click_link("Submit to Start Services")
    wait_for_javascript_to_finish
    #**END Review Page END**#

    #**Submission Confirmation Page**#
    click_link("Go to SPARC Request User Portal")
    wait_for_javascript_to_finish
    #**END Submission Confirmation Page END**#


    #sleep 15


  end

end
