require 'spec_helper'

#=begin
describe 'Catalog Manager' do
  let_there_be_lane
  fake_login_for_each_test

  def create_new_institution(name, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :color => 'blue'
    }
    options = defaults.merge(options)
    click_link 'Create New Institution'
    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
    wait_for_javascript_to_finish
    fill_in 'institution_name', :with => name
    fill_in 'institution_abbreviation', :with => options[:abbreviation]
    select options[:color], :from => 'institution_css_class'
    fill_in 'institution_order', :with => options[:order]
    hideAvailableCheck = first(:xpath, "//input[@id='institution_is_available']")
    if options[:is_available] and hideAvailableCheck.checked? then #if desired available and hide is checked then uncheck
        hideAvailableCheck.click
    elsif not options[:is_available] and not hideAvailableCheck.checked? then #if not desired available and hide is not checked then check
        hideAvailableCheck.click
    end
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name
  end

  def create_new_provider(name,under, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :color => 'blue',
        :display_date => Time.now,
        :federal => 50,
        :corporate => 50,
        :other => 50,
        :member => 50,
        :college_rate_type => 'Federal Rate',
        :federal_rate_type => 'Federal Rate',
        :industry_rate_type => 'Federal Rate',
        :investigator_rate_type => 'Federal Rate',
        :internal_rate_type => 'Federal Rate',
        :foundation_rate_type => 'Federal Rate'
    }
    options = defaults.merge(options)
    click_link under
    click_link 'Create New Provider'
    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
    wait_for_javascript_to_finish

    fill_in 'provider_name', :with => name
    fill_in 'provider_abbreviation', :with => options[:abbreviation]
    select options[:color], :from => 'provider_css_class'
    fill_in 'provider_order', :with => options[:order]
    hideAvailableCheck = first(:xpath, "//input[@id='provider_is_available']")
    if options[:is_available] and hideAvailableCheck.checked? then #if desired available and hide is checked then uncheck
        hideAvailableCheck.click
    elsif not options[:is_available] and not hideAvailableCheck.checked? then #if not desired available and hide is not checked then check
        hideAvailableCheck.click
    end

    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_setup']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    first(:xpath, "//th[contains(text(),'Display Date')]/following-sibling::td/input[@type='text']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[contains(text(),'Effective Date')]/following-sibling::td/input[@type='text']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_federal']").set(options[:federal])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_corporate']").set(options[:corporate])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_other']").set(options[:other])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_member']").set(options[:member])
    #first(:xpath,"//a[contains(text(),'Apply Federal % to All')]").click
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_college_rate_type']/option[contains(text(),'#{options[:college_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_federal_rate_type']/option[contains(text(),'#{options[:federal_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_foundation_rate_type']/option[contains(text(),'#{options[:foundation_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_industry_rate_type']/option[contains(text(),'#{options[:industry_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_investigator_rate_type']/option[contains(text(),'#{options[:investigator_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_internal_rate_type']/option[contains(text(),'#{options[:internal_rate_type]}')]").select_option
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name
  end

  def create_new_program(name,under, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :display_date => Time.now,
        :federal => 50,
        :corporate => 50,
        :other => 50,
        :member => 50,
        :college_rate_type => 'Federal Rate',
        :federal_rate_type => 'Federal Rate',
        :industry_rate_type => 'Federal Rate',
        :investigator_rate_type => 'Federal Rate',
        :internal_rate_type => 'Federal Rate',
        :foundation_rate_type => 'Federal Rate'
    }
    options = defaults.merge(options)
    click_link under
    click_link 'Create New Program'
    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
    wait_for_javascript_to_finish

    fill_in 'program_name', :with => name
    fill_in 'program_abbreviation', :with => options[:abbreviation]
    fill_in 'program_order', :with => options[:order]
    hideAvailableCheck = first(:xpath, "//input[@id='program_is_available']")
    if options[:is_available] and hideAvailableCheck.checked? then #if desired available and hide is checked then uncheck
        hideAvailableCheck.click
    elsif not options[:is_available] and not hideAvailableCheck.checked? then #if not desired available and hide is not checked then check
        hideAvailableCheck.click
    end

    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_setup']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    first(:xpath, "//th[contains(text(),'Display Date')]/following-sibling::td/input[@type='text']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[contains(text(),'Effective Date')]/following-sibling::td/input[@type='text']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_federal']").set(options[:federal])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_corporate']").set(options[:corporate])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_other']").set(options[:other])
    first(:xpath, "//input[@id='pricing_setups_blank_pricing_setup_member']").set(options[:member])
    #first(:xpath,"//a[contains(text(),'Apply Federal % to All')]").click
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_college_rate_type']/option[contains(text(),'#{options[:college_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_federal_rate_type']/option[contains(text(),'#{options[:federal_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_foundation_rate_type']/option[contains(text(),'#{options[:foundation_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_industry_rate_type']/option[contains(text(),'#{options[:industry_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_investigator_rate_type']/option[contains(text(),'#{options[:investigator_rate_type]}')]").select_option
    first(:xpath, "//select[@id='pricing_setups_blank_pricing_setup_internal_rate_type']/option[contains(text(),'#{options[:internal_rate_type]}')]").select_option
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name
  end    

  def create_new_core(name,under, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1
    }
    options = defaults.merge(options)
    click_link under
    click_link 'Create New Core'
    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
    wait_for_javascript_to_finish
    fill_in 'core_name', :with => name
    fill_in 'core_abbreviation', :with => options[:abbreviation]
    fill_in 'core_order', :with => options[:order]
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name
  end

  def create_new_service(name, under, options = {})
    defaults = {
        :otf => false,
        :rate => '25.00',
        :order => 1,
        :abbreviation => name,
        :unit_type => 'slides',
        :unit_factor => 1,
        :display_date => Time.now,
        :unit_minimum => 1,
        :unit_max => 1
    }
    options = defaults.merge(options)
    click_link under
    find(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[text()='Create New Service']").click
    fill_in 'service_name', :with => name
    fill_in 'service_abbreviation', :with => options[:abbreviation]
    fill_in 'service_order', :with => options[:order]
    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_map']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click
    first(:xpath, "//th[text()='Display Dates']/following-sibling::td/input[@type='text']").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[text()='Effective Date']/following-sibling::td/input[@type='text']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//input[@id='pricing_maps_blank_pricing_map_full_rate']").set(options[:rate])
    if options[:otf] then 
        first(:xpath, "//input[@id='otf_checkbox_']").click 
        wait_for_javascript_to_finish
        first(:xpath, "//input[@id='otf_quantity_type_']").set(options[:unit_type])
        first(:xpath, "//input[@id='otf_unit_type_']").set(options[:unit_type])
        first(:xpath, "//table[@id='otf_fields_']//input[@id='unit_factor_']").set(options[:unit_factor])
        first(:xpath, "//input[@id='otf_unit_max_']").set(options[:unit_max])
    else 
        first(:xpath, "//input[@id='clinical_quantity_']").set(options[:unit_type]) 
        first(:xpath, "//input[@id='unit_minimum_']").set(options[:unit_minimum])
        first(:xpath, "//table[@id='pp_fields_']//input[@id='unit_factor_']").set(options[:unit_factor])
    end
    wait_for_javascript_to_finish
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
  end



  it 'Should create crap', :js => true do
    visit catalog_manager_root_path

    create_new_institution 'someInst'
    create_new_provider 'someProv', 'someInst'
    create_new_program 'someProg', 'someProv'
    create_new_core 'someCore', 'someProg'
    create_new_service 'someService', 'someCore', :otf => false
    create_new_service 'someService2', 'someCore', :otf => true
    visit root_path
    sleep 120
  end  
end
#=end

=begin
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
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")


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
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
        #should display field_with_errors divs near fields without info
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")

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
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
        #should display field_with_errors divs near fields without info
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")

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
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")
        #should display field_with_errors divs near field without info
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")

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
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Short Title:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Protocol Title:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Proposal Funding Status:*']")
    #page.should_not have_xpath("//div[@class='field_with_errors']/label[text()='Sponsor Name:*']")   
        #should display field_with_errors divs near field without info
    #page.should have_xpath("//div[@class='field_with_errors']/label[text()='Funding Source:*']") 
     
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

    click_button "Add Authorized User"
        #should have 'Role can't be blank' error
    page.should have_xpath("//div[@id='user_detail_errors']/ul/li[contains(text(),'Role can')]")
    page.should have_xpath("//div[@class='field_with_errors']/label[text()='Role:*']")

    select "Billing/Business Manager", :from => "project_role_role"
    click_button "Add Authorized User"
    wait_for_javascript_to_finish

    find('.continue_button').click
    wait_for_javascript_to_finish
    #**END Select Users END**#

    #**Select Study**#
        #Remove services
    find(:xpath,"//a[@id='line_item-3' and @class='remove-button']").click
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('1') #should display 1 service
    find(:xpath,"//a[@id='line_item-4' and @class='remove-button']").click
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('0') #should display 0 services
    click_link("Save & Continue")
    wait_for_javascript_to_finish
    #**END Select Study END**#

    #**Enter Protocol Dates**#
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

        #Should have no services and instruct to add some
    page.should have_xpath("//div[@class='instructions' and contains(text(),'continue unless you have services in your cart.')]")
        #re-adding services
    click_link("Back to Catalog")
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
    find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should only display 2 services
    find('.submit-request-button').click
    wait_for_javascript_to_finish
    click_link("Save & Continue")
    wait_for_javascript_to_finish

        #Select Recruitment Start and End Date    
        #########################

        #edit Arm 1
    fill_in "study_arms_attributes_0_subject_count", :with => "5" # 5 subjects
    fill_in "study_arms_attributes_0_visit_count", :with => "5" # 5 visits
    wait_for_javascript_to_finish
        #add Arm 2
    click_link("Add Arm")
    wait_for_javascript_to_finish
    find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell']/input[@type!='hidden']").set("ARM 2") #name arm2
    find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell skinny_fields']/input[contains(@name,'subject_count')]").set("5") # 5 subjects
    find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell skinny_fields']/input[contains(@name,'visit_count')]").set("5") # 5 visits
    wait_for_javascript_to_finish

    click_link("Save & Continue")
    #wait_for_javascript_to_finish
    #**END Enter Protocol Dates END**#

    #**Completing Visit Calender**#
        #save unit prices
    arm1UnitPrice = find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
    arm2UnitPrice = find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
    otfUnitPrice = find(:xpath, "//td[contains(text(),'CDW')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
        #total per study should be $0.00
    find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(0.0) #arm1
    find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(0.0) #arm2
        #total per patient should be $0.00
    find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq(0.0) #arm1
    find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq(0.0) #arm2
        #set days in increasing order on ARM 1
    find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_1']").set("1")
    find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_2']").set("2")
    find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_3']").set("3")
    find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_4']").set("4")
    find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_5']").set("5")

    check('visits_1') #1st checkbox ARM 1
    wait_for_javascript_to_finish
    totPerStudy = (arm1UnitPrice * 1 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
    find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 per patient total should eq (unitprice * 1 * #patients)
    find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 1).round(2)) #ARM1 per patient total should eq (unitprice * 1)
    
    check('visits_5') #3rd checkbox ARM 1
    wait_for_javascript_to_finish
    totPerStudy = (arm1UnitPrice * 2 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
    find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 per patient total should eq (unitprice * 2 * #patients)
    find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 2).round(2)) #ARM1 per patient total should eq (unitprice * 2)
    
    check('visits_9') #5th checkbox ARM 1
    wait_for_javascript_to_finish
    totPerStudy = (arm1UnitPrice * 3 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
    find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 per patient total should eq (unitprice * 3 * #patients)
    find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 3).round(2)) #ARM1 per patient total should eq (unitprice * 3)
    
        #set days in increasing order on ARM 2
    find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_1']").set("1")
    find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_2']").set("2")
    find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_3']").set("3")
    find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_4']").set("4")
    find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_5']").set("5")
      
    check('visits_12') #2nd checkbox ARM 2
    wait_for_javascript_to_finish
    totPerStudy = (arm2UnitPrice * 1 * find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
    find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM2 per patient total should eq (unitprice * 1 * #patients)
    find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq((arm2UnitPrice * 1).round(2)) #ARM2 per patient total should eq (unitprice * 1)

    check('visits_14') #4th checkbox ARM 2
    wait_for_javascript_to_finish
    totPerStudy = (arm2UnitPrice * 2 * find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
    find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM2 per patient total should eq (unitprice * 2 * #patients)
    find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq((arm2UnitPrice * 2).round(2)) #ARM2 per patient total should eq (unitprice * 2)

    first(:xpath, "//input[@class='line_item_quantity']").set("3") #set CDW quantity to 3
    find(:xpath, "//td[contains(@class,'otf_total total')]").text[1..-1].to_f.should eq((otfUnitPrice*3).round(2)) #otf total should eq (unitprice * 3)
    
    click_link("Save & Continue")
    wait_for_javascript_to_finish
    #**END Completing Visit Calender ENDß**#

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


    #sleep 5
    #a = page.driver.browser.switch_to.alert
    #a.accept

    #sleep 15



  end

end
=end


