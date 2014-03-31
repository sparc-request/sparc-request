require 'spec_helper'

describe 'A Happy Test' do
  let_there_be_lane
  fake_login_for_each_test

  let!(:institution)  {FactoryGirl.create(:institution,id: 53,name: 'Medical University of South Carolina', order: 1,abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,id: 10,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',parent_id: institution.id,abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,id:54,type:'Program',name:'Office of Biomedical Informatics',order:1,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:program2) {FactoryGirl.create(:program,id:5,type:'Program',name:'Clinical and Translational Research Center (CTRC)',order:2,parent_id:provider.id,abbreviation:'Informatics',process_ssrs:0,is_available:1)}
  let!(:core) {FactoryGirl.create(:core,id:33,type:'Core',name:'Clinical Data Warehouse',order:1,parent_id:program.id,abbreviation:'Clinical Data Warehouse')}
  let!(:core2) {FactoryGirl.create(:core,id:8,type:'Core',name:'Nursing Services',abbreviation:'Nursing Services',order:1,parent_id:program2.id)}
  let!(:service) {FactoryGirl.create(:service,id:67,name:'MUSC Research Data Request (CDW)',abbreviation:'CDW',order:1,cpt_code:'',organization_id:core.id)}
  let!(:service2) {FactoryGirl.create(:service,id:16,name:'Breast Milk Collection',abbreviation:'Breast Milk Collection',order:1,cpt_code:'',organization_id:core2.id)}
  let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_setup2) { FactoryGirl.create(:pricing_setup, organization_id: program2.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map) {FactoryGirl.create(:pricing_map,service_id:service.id, unit_type: 'Per Query', unit_factor: 1, is_one_time_fee: 1, display_date: Time.now - 1.day, full_rate: 200, exclude_from_indirect_cost: 0, unit_minimum:1)}
  let!(:pricing_map2) {FactoryGirl.create(:pricing_map, service_id: service2.id, unit_type: 'Per patient/visit', unit_factor: 1, is_one_time_fee: 0, display_date: Time.now - 1.day, full_rate: 636, exclude_from_indirect_cost: 0, unit_minimum: 1)}
  let!(:service_provider)    { FactoryGirl.create(:service_provider, organization_id: program.id, identity_id: jug2.id)}
  let!(:service_provider2)    { FactoryGirl.create(:service_provider, organization_id: program2.id, identity_id: jug2.id)}
  # let!(:pricing_map2)       { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20) }

    #after :each do
    #  wait_for_javascript_to_finish
    #end

  it 'should make you feel happy', :js => true do
    visit root_path

    #puts '#' * 50
    #puts pricing_map.service_id
    #puts pricing_map2.service_id
    #puts '#' * 50

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

    check('visits_2') #Check 1st visit
    check('visits_6') #Check 2nd visit
    check('visits_10') #Check 3rd visit

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
