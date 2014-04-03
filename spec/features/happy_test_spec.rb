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

    #**Submit a service request**#

    page.should_not have_xpath("//div[@id='submit_error' and @style!='display: none']")
    find('.submit-request-button').click #Submit with no services
    wait_for_javascript_to_finish
    page.should have_xpath("//div[@id='submit_error' and @style!='display: none']") #should have error dialog
    click_button('Ok') 

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

    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should display 2 services
    find(:xpath,"//a[@id='line_item-1' and @class='remove-button']").click  #remove first service
    wait_for_javascript_to_finish
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('1') #should display 1 service
    find(:xpath,"//a[@id='line_item-2' and @class='remove-button']").click #remove last service
    wait_for_javascript_to_finish
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('0') #should display no services

    click_link("Office of Biomedical Informatics")
    wait_for_javascript_to_finish
    click_button("Add") #re-add first service
    wait_for_javascript_to_finish

    click_link("Clinical and Translational Research Center (CTRC)")
    wait_for_javascript_to_finish
    click_button("Add") #re-add last service
    wait_for_javascript_to_finish
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should display 2 services

    click_button("Add") #add last service a second time
    wait_for_javascript_to_finish
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should only display 2 services

    find('.submit-request-button').click
    wait_for_javascript_to_finish

    #**END Submit a service request END**#

    ServiceRequest.find(1).line_items.count.should eq(2) #Should have 2 Services
    
    #**Create a new Study**#

    #should not have any errors displayed
    page.should_not have_xpath("//div[@id='errorExplanation']")

    click_link("Save & Continue") #click continue without study/project selected
    wait_for_javascript_to_finish

    #should only have 1 error, with specific text
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[text()='You must identify the service request with a study/project before continuing.']")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[text()!='You must identify the service request with a study/project before continuing.']")

    click_link("New Study")
    wait_for_javascript_to_finish

    find('.continue_button').click #click continue with no form info
    wait_for_javascript_to_finish

    #should display error div with 4 errors
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
    #should display field_with_errors divs near fields without info
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")


    fill_in "study_short_title", :with => "Bob" #fill in short title
    find('.continue_button').click #click continue without Title, Funding Status, Sponsor Name
    wait_for_javascript_to_finish

    #should not display error div for field with info
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
    #should display error div with 3 errors
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
    #should not display field_with_errors divs near field with info
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    #should display field_with_errors divs near fields without info
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")

    fill_in "study_title", :with => "Dole" #fill in title
    find('.continue_button').click #click continue without Funding Status, Sponsor Name
    wait_for_javascript_to_finish

    #should not display error div for filled in info
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
    #should display error div with 2 errors for missing info
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
    #should not display field_with_errors divs near fields with info
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    #should display field_with_errors divs near fields without info
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")

    fill_in "study_sponsor_name", :with => "Captain Kurt 'Hotdog' Zanzibar" #fill in sponsor name
    find('.continue_button').click #click continue without Funding Status
    wait_for_javascript_to_finish

    #should not display error divs for filled in info
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
    #should display funding status missing error
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
    #should not display field_with_errors divs near fields with info
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")
    #should display field_with_errors divs near field without info
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")

    select "Funded", :from => "study_funding_status" #select funding status
    find('.continue_button').click #click continue without Funding Source
    wait_for_javascript_to_finish   

    #should not display error divs for filled in info
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
    page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
    #should display funding source missing error
    page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding source')]")
    #should not display field_with_errors divs near fields with info
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")   
    #should display field_with_errors divs near field without info
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Funding Source:*']") 
     
    select "Federal", :from => "study_funding_source" #select funding source

    find('.continue_button').click
    wait_for_javascript_to_finish

    #**END Create a new Study END**#

    #**Select Users**#
    click_button "Add Authorized User"
    #should have 'Role can't be blank' error
    page.should have_xpath("//div[@id='user_detail_errors']/ul/li[contains(text(),'Role can')]")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Role:*']")

    select "Primary PI", :from => "project_role_role"
    click_button "Add Authorized User"
    wait_for_javascript_to_finish
    fill_in "user_search_term", :with => "bjk7"
    wait_for_javascript_to_finish
    page.find('a', :text => "Brian Kelsey (kelsey@musc.edu)", :visible => true).click()
    wait_for_javascript_to_finish
    sleep 100
    select "Billing/Business Manager", :from => "project_role_role"
    click_button "Add Authorized User"
    wait_for_javascript_to_finish

    find('.continue_button').click
    wait_for_javascript_to_finish
    #**END Select Users END**#

    click_link("Save & Continue")
    wait_for_javascript_to_finish

    #Select start and end date
    strtDay = Time.now.strftime("%-d") # Today's Day
    endDay = (Time.now + 7.days).strftime("%-d") # 7 days from today

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

    #Select Recruitment Start and End Date    
    #########################

    #Add Arm 1
    fill_in "study_arms_attributes_0_subject_count", :with => "5" # 5 subjects
    fill_in "study_arms_attributes_0_visit_count", :with => "5" # 5 visit
    wait_for_javascript_to_finish

    click_link("Save & Continue")
    wait_for_javascript_to_finish

    #Completing Visit Calender
      #set days in increasing order
    first(:xpath, "//input[@id='day' and @class='visit_day position_1']").set("1")
    first(:xpath, "//input[@id='day' and @class='visit_day position_2']").set("2")
    first(:xpath, "//input[@id='day' and @class='visit_day position_3']").set("3")
    first(:xpath, "//input[@id='day' and @class='visit_day position_4']").set("4")
    first(:xpath, "//input[@id='day' and @class='visit_day position_5']").set("5")
      #check 1st, 3rd, and 5th visit
    check('visits_2')
    check('visits_6')
    check('visits_10')
      #set CDW quantity to 3
    first(:xpath, "//input[@class='line_item_quantity']").set("3")
    click_link("Save & Continue")
    wait_for_javascript_to_finish

    #Documents page

    #click_link("Add a New Document")
    #all('process_ssr_organization_ids_').each {|a| check(a)}
    #select "Other", :from => "doc_type"

    click_link("Save & Continue")
    wait_for_javascript_to_finish

    #Review Page
    click_link("Submit to Start Services")
    wait_for_javascript_to_finish

    #Submission Confirmation Page
    click_link("Go to SPARC Request User Portal")
    wait_for_javascript_to_finish


    #sleep 5
    #a = page.driver.browser.switch_to.alert
    #a.accept

    #sleep 15



  end

end
