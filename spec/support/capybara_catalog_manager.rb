module CapybaraCatalogManager

  def add_service_provider(id="leonarjp")
    find(:xpath, "//div[text()='User Rights']").click
    wait_for_javascript_to_finish
    fill_in "new_sp", :with => "#{id}"
    sleep 3
    response = first(:xpath, "//a[contains(text(),'#{id}') and contains(text(),'@musc.edu')]", :visible => true)
    if response.nil? or not(response.visible?)
        fill_in "new_sp", :with => ""
        sleep 2
        fill_in "new_sp", :with => "#{id}"
        sleep 4
        first(:xpath, "//a[contains(text(),'#{id}') and contains(text(),'@musc.edu')]", :visible => true).click 
    else response.click end
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def fillOutCWF(org)
    wait_for_javascript_to_finish
    find("div#cwf_wrapper #cwf_fieldset", :visible => true).click
    wait_for_javascript_to_finish
    sleep 3
    if org=='program' then cwfCheckBox = first("input#program_show_in_cwf")
    else cwfCheckBox = first("input#core_show_in_cwf") end 
    if not cwfCheckBox.checked? then cwfCheckBox.click end
    wait_for_javascript_to_finish

    i = 1
    inputID = 'program_position_in_cwf'
    if org=='core' then inputID = 'core_position_in_cwf' end
    first(:xpath, "//input[@id='#{inputID}']").set(i)
    first("#save_button").click
    wait_for_javascript_to_finish    
    while not first(:xpath, "//div[@id='errorExplanation']/ul/li[contains(text(),'Position_in_cwf')]").nil? do
        i+=1
        first(:xpath, "//input[@id='#{inputID}']").set(i)
        first("#save_button").click
        wait_for_javascript_to_finish
    end

    fill_in "new_cp", :with => "Julia"
    sleep 2
    response = first(:xpath, "//a[contains(text(),'Julia') and contains(text(),'@musc.edu')]")
    if not(response.nil?) and response.visible? then response.click
    else
        sleep 1
        wait_for_javascript_to_finish
        first(:xpath, "//a[contains(text(),'Julia') and contains(text(),'@musc.edu')]",:visible => true).click
    end
    # if response.nil? or not(response.visible?) 
        # wait_for_javascript_to_finish
        # first(:xpath, "//a[contains(text(),'Julia') and contains(text(),'@musc.edu')]").click
    # else response.click end
    wait_for_javascript_to_finish   
  end

  def subsidyInfo(org='provider')   
    #Subsidy Information
    sleep 3
    first("#pricing .subsidy_percentage").set("50") #max percentage
    first("#pricing .subsidy_dollar").set("500") #max dollar cap
    select "Federal", :from => "funding_source"
    # find(".excluded_funding_td select").click
    # wait_for_javascript_to_finish
    # find(".excluded_funding_td option[value='Federal']").select_option #exclude federal
    first(".add_new_excluded_funding_source").click
    wait_for_javascript_to_finish
    within ("ul.excluded_funding_sources") do
        page.should have_content("Federal") #should have Federal excluded
    end
  end

  def autoPriceAdjust
    #Increase/Decrease Rates
    first(:xpath, "//input[@class='increase_decrease_rates']").click
    wait_for_javascript_to_finish
    numerical_day = Time.now.strftime("%-d") # Today's Day
    currentBox = find(:xpath, "//div[contains(@class,'ui-dialog ') and contains(@style,'display: block;')]")
    within currentBox do
        first(:xpath, ".//input[contains(@class, 'percent_of_change')]").set("20") #percent change
        first(:xpath, ".//input[@display='display_date']").click #display date
        wait_for_javascript_to_finish
        # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{numerical_day}']").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } #today
        wait_for_javascript_to_finish
        first(:xpath, ".//input[@display='effective_date']").click #effective date
        wait_for_javascript_to_finish
        # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{numerical_day}']").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } #today
        wait_for_javascript_to_finish     
        first(:xpath, ".//span[@class='ui-button-text' and text()='Submit']").click   
        wait_for_javascript_to_finish     
    end
  end

  def isCollapsed?(under)
    if have_xpath("//a[text()='#{under}']/preceding-sibling::ins[contains(@class,'triangle-1-se')]", :visible => true)
        return false
    end
    return true
  end

  def clickCreateNew orgType, under
    wait_for_javascript_to_finish
    if isCollapsed? under then click_link under end
    wait_for_javascript_to_finish
    link = first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New #{orgType}')]", :visible => true)
    if not(link.nil?) and link.visible?
        wait_for_javascript_to_finish
        begin 
            link.click
        rescue
            wait_for_javascript_to_finish
            begin 
                first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New #{orgType}')]", :visible => true).click
            rescue
                click_link under
                wait_for_javascript_to_finish
                first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New #{orgType}')]", :visible => true).click
            end
        end
    else
        click_link under
        wait_for_javascript_to_finish
        link = first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New #{orgType}')]", :visible => true)
        link.click
    end

  end

  def setAlertNameTo name
    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
  end

  def createTags
    Tag.create(:name => "ctrc") # Displays as "Nexus"
    Tag.create(:name => "required forms") # Displays as "Required forms"
    Tag.create(:name => "clinical work fulfillment") # Displays as "Clinical work fulfillment"
    Tag.create(:name => "epic") # Displays as "Epic"
  end


  def setTag(name)
    wait_for_javascript_to_finish
    tagExist = first(:xpath, "//span[@style='margin-right:10px;']/span/label[contains(text(),'#{name}')]")
    if tagExist.nil? then return end #if tag does not exist, quit here. 
    checkBox = find(:xpath, "//span[@style='margin-right:10px;']/span/label[contains(text(),'#{name}')]/parent::span/following-sibling::span/input[@type='checkbox']")
    if not checkBox.checked? then checkBox.click end
  end 


  def create_new_institution(name, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :color => 'blue',
        :tags => []
    }
    options = defaults.merge(options)
    first(:xpath, "//a[contains(text(),'Create New Institution')]").click

    setAlertNameTo name
    
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

    options[:tags].each do |tagName| setTag tagName end

    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    # click_link name
  end



  def create_new_provider(name, under, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :color => 'blue',
        :process_ssrs => false,
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
        :foundation_rate_type => 'Federal Rate',
        :tags => []
    }
    options = defaults.merge(options)

    clickCreateNew "Provider", under

    setAlertNameTo name
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
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end

    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_setup']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    wait_for_javascript_to_finish
    first(:xpath, "//th[contains(text(),'Display Date')]/following-sibling::td/input[@type='text']").click
    wait_for_javascript_to_finish
    # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{stDay}']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[contains(text(),'Effective Date')]/following-sibling::td/input[@type='text']").click
    wait_for_javascript_to_finish
    # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{stDay}']").click
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
    
    autoPriceAdjust

    subsidyInfo

    add_service_provider "Julia"
    wait_for_javascript_to_finish
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    # click_link name

  end



  def create_new_program(name, under, options = {})
    defaults = {
        :abbreviation => name,
        :order => 1,
        :is_available => true,
        :process_ssrs => false,
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
        :foundation_rate_type => 'Federal Rate',
        :tags => []
    }
    options = defaults.merge(options)

    clickCreateNew "Program", under

    setAlertNameTo name
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
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end

    if options[:tags].include? "Clinical work fulfillment" then fillOutCWF('program') end

    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_setup']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    wait_for_javascript_to_finish
    first("input.datepicker.display_date").click
    # first(:xpath, "//th[contains(text(),'Display Date')]/following-sibling::td/input[@type='text']").click
    wait_for_javascript_to_finish
    # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{stDay}']").click
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[contains(text(),'Effective Date')]/following-sibling::td/input[@type='text']").click
    wait_for_javascript_to_finish
    # find(:xpath, "//div/table/tbody/tr/td[@data-handler='selectDay']/a[text()='#{stDay}']").click
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
    
    autoPriceAdjust

    subsidyInfo 'program'

    add_service_provider "Julia"
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    # click_link name
  end    



  def create_new_core(name, under, options = {})
    defaults = {
        :abbreviation => name,
        :is_available => true,
        :order => 1,
        :process_ssrs => false,
        :tags => []
    }
    options = defaults.merge(options)

    clickCreateNew "Core", under

    setAlertNameTo name
    wait_for_javascript_to_finish

    fill_in 'core_name', :with => name
    fill_in 'core_abbreviation', :with => options[:abbreviation]
    fill_in 'core_order', :with => options[:order]
    hideAvailableCheck = first(:xpath, "//input[@id='core_is_available']")
    if options[:is_available] and hideAvailableCheck.checked? then #if desired available and hide is checked then uncheck
        hideAvailableCheck.click
    elsif not options[:is_available] and not hideAvailableCheck.checked? then #if not desired available and hide is not checked then check
        hideAvailableCheck.click
    end
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end
    if options[:tags].include? "Clinical work fulfillment" then fillOutCWF('core') end

    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end 
    
    wait_for_javascript_to_finish
    subsidyInfo 'core'

    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    # click_link name
  end



  def create_new_service(name, under, options = {})
    defaults = {
        :otf => false,
        :is_available => true,
        :rate => '25.00',
        :process_ssrs => false,
        :order => 1,
        :abbreviation => name,
        :unit_type => 'samples',
        :quantity_type => 'slides',
        :unit_factor => 1,
        :display_date => Time.now,
        :unit_minimum => 1,
        :unit_max => 1,
        :linked => {:on? => false, :service => name+'', :required? => false, :quantity? => false, :quantityNum => 5},
        :tags => []
    }
    options = defaults.merge(options)

    clickCreateNew "Service", under
    wait_for_javascript_to_finish



    # wait_until(20){first(:xpath, "//td/input[@id='service_name']", :visible => true)}
    fill_in 'service_name', :with => name
    fill_in 'service_abbreviation', :with => options[:abbreviation]
    fill_in 'service_order', :with => options[:order]
    hideAvailableCheck = first(:xpath, "//input[@id='service_is_available']")
    if options[:is_available] and hideAvailableCheck.checked? then #if desired available and hide is checked then uncheck
        hideAvailableCheck.click
    elsif not options[:is_available] and not hideAvailableCheck.checked? then #if not desired available and hide is not checked then check
        hideAvailableCheck.click
    end
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end

    find(:xpath, "//div[text()='Pricing']").click
    find(:xpath, "//input[@class='add_pricing_map']").click
    first(:xpath, "//a[@href='#' and contains(text(),'Effective on')]").click

    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    wait_for_javascript_to_finish
    first("input.datepicker.pricing_map_display_date").click #Trigger datepicker on Display Date input
    wait_for_javascript_to_finish
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[text()='Effective Date']/following-sibling::td/input[@type='text']").click #Trigger datepicker on Effective Date input
    wait_for_javascript_to_finish
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day

    first(:xpath, "//input[@id='pricing_maps_blank_pricing_map_full_rate']").set(options[:rate])
    if options[:otf] then 
        first(:xpath, "//input[@id='otf_checkbox_']").click 
        wait_for_javascript_to_finish
        first(:xpath, "//input[@id='otf_quantity_type_']").set(options[:quantity_type])
        first(:xpath, "//input[@id='otf_unit_type_']").set(options[:unit_type])
        first(:xpath, "//table[@id='otf_fields_']//input[@id='unit_factor_']").set(options[:unit_factor])
        first(:xpath, "//input[@id='otf_unit_max_']").set(options[:unit_max])
    else 
        first(:xpath, "//input[@id='clinical_quantity_']").set(options[:unit_type]) 
        first(:xpath, "//input[@id='unit_minimum_']").set(options[:unit_minimum])
        first(:xpath, "//table[@id='pp_fields_']//input[@id='unit_factor_']").set(options[:unit_factor])
    end
    if options[:linked][:on?] then 
        wait_for_javascript_to_finish
        first(:xpath, "//fieldset[@class='actions']").click
        first(:xpath, "//input[@id='save_button']").click
        wait_for_javascript_to_finish
        first(:xpath, "//div[text()='Related Services']").click # click_link "Related Services"
        wait_for_javascript_to_finish
        sleep 2
        fill_in "new_rs", :with => options[:linked][:service]
        sleep 1
        wait_until{first(:xpath, "//ul[contains(@class,'ui-autocomplete')]/li[@class='ui-menu-item']/a[contains(text(),'#{options[:linked][:service]}')]")}.click
        wait_for_javascript_to_finish

        serviceAdded = first(:xpath, "//td[contains(text(),'#{options[:linked][:service]}')]")
        if serviceAdded.nil? then wait_until{find(:xpath, "//td[contains(text(),'#{options[:linked][:service]}')]")} end

        requiredCheck = wait_until{find(:xpath, "//td[text()='#{options[:linked][:service]}']/following-sibling::td/input[@class='optional']")}
        if not requiredCheck.checked? and options[:linked][:required?] then requiredCheck.click end
        wait_for_javascript_to_finish
        
        wait_until{first(:xpath, "//td[text()='#{options[:linked][:service]}']/following-sibling::td/input[contains(@class,'linked_quantity')]")}
        quantityCheck = wait_until{first(:xpath, "//td[text()='#{options[:linked][:service]}']/following-sibling::td/input[contains(@class,'linked_quantity')]")}
        if not quantityCheck.checked? and options[:linked][:quantity?] then 
            quantityCheck.click
            wait_until{first(:xpath, "//td[text()='#{options[:linked][:service]}']/following-sibling::td/input[contains(@class,'linked_quantity_total')]")}.set(options[:linked][:quantityNum])
        end
        wait_for_javascript_to_finish

    end
    wait_for_javascript_to_finish
    first(:xpath, "//fieldset[@class='actions']").click
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
  end
end
