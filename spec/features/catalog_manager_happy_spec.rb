require 'spec_helper'


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
    first(:xpath, "//fieldset[@class='actions']").click
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