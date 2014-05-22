module CapybaraCatalogManager

  def add_service_provider(id="leonarjp")
    find(:xpath, "//div[text()='User Rights']").click
    wait_for_javascript_to_finish
    fill_in "new_sp", with: "#{id}"
    wait_for_javascript_to_finish

    response = wait_until{first(:xpath, "//a[contains(text(),'#{id}') and contains(text(),'@musc.edu')]")}
    if not response.nil? then response.click 
    else first(:xpath, "//a[contains(text(),'#{id}') and contains(text(),'@musc.edu')]").click end
    wait_for_javascript_to_finish

    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def fillOutCWF
    wait_for_javascript_to_finish
    find(:xpath, "//div[text()='Clinical Work Fulfillment']").click
    wait_for_javascript_to_finish
    cwfCheckBox = first(:xpath, "//input[@id='program_show_in_cwf']")
    if not cwfCheckBox.checked? then cwfCheckBox.click end
    wait_for_javascript_to_finish

    i = 1
    first(:xpath, "//input[@id='program_position_in_cwf']").set(i)
    first("#save_button").click
    wait_for_javascript_to_finish    
    while not first(:xpath, "//div[@id='errorExplanation']/ul/li[contains(text(),'Position_in_cwf')]").nil? do
        i+=1
        first(:xpath, "//input[@id='program_position_in_cwf']").set(i)
        first("#save_button").click
        wait_for_javascript_to_finish
    end

    fill_in "new_cp", with: "Julia"
    wait_for_javascript_to_finish
    response = wait_until{first(:xpath, "//a[contains(text(),'Julia') and contains(text(),'@musc.edu')]")}
    if not response.nil? then response.click 
    else first(:xpath, "//a[contains(text(),'Julia') and contains(text(),'@musc.edu')]").click end
    wait_for_javascript_to_finish   
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

    options[:tags].each do |tagName| setTag tagName end

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
    wait_for_javascript_to_finish
    cnpLink = first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New Provider')]")
    if cnpLink.visible? then
        begin
            cnpLink.click
        rescue
            click_link under
            cnpLink.click
        end
    else
        click_link under
        cnpLink.click
    end

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
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end

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
    
    add_service_provider "Julia"
    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name

  end



  def create_new_program(name,under, options = {})
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
    wait_for_javascript_to_finish
    cnpLink = first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New Program')]")
    if cnpLink.visible? then
        begin
            cnpLink.click
        rescue
            click_link under
            cnpLink.click
        end
    else
        click_link under
        cnpLink.click
    end

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
    if options[:process_ssrs] then 
        splitCheckBox = find(:xpath, "//input[@id='program_process_ssrs']")
        if not splitCheckBox.checked? then splitCheckBox.click end
    end
    options[:tags].each do |tagName| setTag tagName end

    if options[:tags].include? "Clinical work fulfillment" then fillOutCWF end

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
        :is_available => true,
        :order => 1,
        :process_ssrs => false,
        :tags => []
    }
    options = defaults.merge(options)
    wait_for_javascript_to_finish
    cncLink = first(:xpath, "//a[text()='#{under}']/following-sibling::ul//a[contains(text(),'Create New Core')]")
    if cncLink.visible? then
        begin
            cncLink.click
        rescue
            click_link under
            cncLink.click
        end
    else
        click_link under
        cncLink.click
    end

    a = page.driver.browser.switch_to.alert
    a.send_keys(name)
    a.accept
    click_link name
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


    first(:xpath, "//input[@id='save_button']").click
    wait_for_javascript_to_finish
    click_link name
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
    wait_for_javascript_to_finish
    cnsLink = first(:xpath, "//a[contains(text(),'#{under}')]/following-sibling::ul//a[contains(text(),'Create New Service')]")
    if cnsLink.visible? then
        cnsLink.click
        wait_for_javascript_to_finish
    else
        click_link under
        wait_for_javascript_to_finish
        cnsLink.click
        wait_for_javascript_to_finish
    end
    wait_for_javascript_to_finish

    wait_until(20){first(:xpath, "//td/input[@id='service_name']")}
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
    first(:xpath, "//th[text()='Display Dates']/following-sibling::td/input[@type='text']").click
    stDay = (options[:display_date]).strftime("%-d") # Today's Day
    page.execute_script %Q{ $("a.ui-state-default:contains('#{stDay}')").filter(function(){return $(this).text()==='#{stDay}';}).trigger("click") } # click on start day
    first(:xpath, "//th[text()='Effective Date']/following-sibling::td/input[@type='text']").click
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
        fill_in "new_rs", :with => options[:linked][:service]
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
