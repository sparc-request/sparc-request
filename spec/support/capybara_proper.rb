module CapybaraProper

    class ServiceWithAddress
        def initialize(options = {})
            defaults = {
                :instit => false,
                :prov => false,
                :prog => false,
                :core => false,
                :name => false,
                :short => false,
                :otf => false,
                :unitPrice => 0
            }
            options = defaults.merge(options)
            if not options[:short] then options[:short] = options[:name] end
            @instit = options[:instit]
            @prov = options[:prov]
            @prog = options[:prog]
            @core = options[:core]
            @name = options[:name]
            @short = options[:short]
            @otf = options[:otf]
            @unitPrice = options[:unitPrice]
            @totalPrice = 0
            @checked = 0
            @subjects = 0
        end
        attr_reader :instit, :prov, :prog, :core, :name, :short, :otf, :unitPrice
        attr_accessor :totalPrice, :checked, :subjects
    end




    def clickOffAndWait
        #allows javascript to complete
        #by clicking in a nonactive part of the page
        #then calls wait for javascript to finish method.
        first(:xpath, "//div[@class='welcome']").click
        wait_for_javascript_to_finish
    end    


    def addService(serviceName)
        #if service is visible on screen,
        #clicks add button next to specified serviceName.
        #otherwise, searches for the service in the searchbox
        #and adds it from there
        clickOffAndWait
        addServiceButton = first(:xpath, "//a[contains(text(),'#{serviceName}')]/parent::span/parent::span//button[text()='Add']")
        if not addServiceButton.nil? then #if service is on screen then add it
            addServiceButton.click
            wait_for_javascript_to_finish
        else #else use the search box to find the service then add it
            wait_until {first(:xpath, "//input[@id='service_query']")}.set(serviceName)
            wait_for_javascript_to_finish
            wait_until {first(:xpath, "//li[@class='search_result']/button[@class='add_service']")}.click
            wait_for_javascript_to_finish
        end
    end


    def removeService(serviceName)
        #clicks the (red X) next to service names in the 'My Services' box to remove them
        #problem here where short names are not same as long names of services...
        find(:xpath,"//div[@class='line_item']/div[contains(text(),'#{serviceName}')]/following-sibling::a[@class='remove-button']").click
        clickOffAndWait
    end


    def navigateCatalog(instit = false, prov = false, prog = false, core = false)
        #navigates through the catalog
        #can navigate from an institution to a core
        #if a field is left false, then stop navigating at that field

        if instit #if institution is not false
            institLink = wait_until {first(:xpath,"//h3/a[contains(text(),'#{instit}')]/preceding-sibling::span[contains(@class,'triangle-1')]")}
            if institLink['class'].include? "triangle-1-e"
                institLink.click #if dropdown not expanded then expand
                clickOffAndWait
            end

            if prov #if institution and provider are not false
                provLink = wait_until {first(:xpath,"//h3/a[contains(text(),'#{prov}')]/preceding-sibling::span[contains(@class,'triangle-1')]")}
                if provLink['class'].include? "triangle-1-e"
                    provLink.click #if dropdown not expanded then expand
                    clickOffAndWait
                end

                if prog #if institution, provider, and program are not false
                    click_link prog #click program link
                    clickOffAndWait
                    if first(:xpath, "//div[@class='provider-details-view']/div[contains(text(),'#{prog}')]").nil?
                        click_link prog #sometimes first click doesn't take hold, gives it another try.
                        clickOffAndWait
                    end

                    if core #if institution, provider, program, and core are not false
                        coreLink = wait_until {first(:xpath,"//h3/a[contains(text(),'#{core}')]/preceding-sibling::span[contains(@class,'triangle-1')]")}
                        if coreLink['class'].include? "triangle-1-e"
                            coreLink.click #if dropdown not expanded then expand
                            clickOffAndWait
                        end
                    end

                else return #if program is not provided (still false) end method 
                end

            else return #if provider is not provided (still false) end method
            end

        else return #if institution is not provided (still false) end method
        end

    end


    def submitExpectError
        #submits the service request and
        #asserts that an error is expected.
        #this is intended to be used before adding services 
        #to check that an error is given for a request that 
        #is submitted with no services added.
        page.should_not have_xpath("//div[@id='submit_error' and @style!='display: none']") #should not have error
        find('.submit-request-button').click #Submit click
        wait_for_javascript_to_finish
        page.should have_xpath("//div[@id='submit_error' and @style!='display: none']") #should have error dialog
        click_button('Ok') #acknowledge error 
        wait_for_javascript_to_finish
    end


    def checkLineItemsNumber(numberExpected)
        #asserts that the line item count
        #shoud equal the number expected.
        wait_until {find(:xpath, "//input[@id='line_item_count']")}['value'].should eq(numberExpected)
    end 


    def addAllServices(services = [])
        #expects list of ServiceWithAddress objects
        if services.empty? 
            return #if no services passed in, end method here.
        end

        services.each do |s| #iterates over services
            navigateCatalog(s.instit,s.prov,s.prog,s.core) #navigates to each service
            addService s.name #adds service
        end
        checkLineItemsNumber "#{services.length}" #check if correct number of services displayed
    end  


    def removeAllServices
        #finds all line item remove buttons and clicks them
        servicesLeft = find(:xpath, "//input[@id='line_item_count']")['value']
        while servicesLeft.to_i > 0 do
            first(:xpath, "//div[@class='line_item']//a[@class='remove-button']").click
            wait_for_javascript_to_finish
            servicesLeft = find(:xpath, "//input[@id='line_item_count']")['value']
        end
        checkLineItemsNumber '0'
    end




    def submitServiceRequest (services = [])
        #expects a list of ServiceWithAddress objects
        submitExpectError #checks submit with no services error display

        addAllServices(services)#adds all services in 'services' list

        count = services.length #saves total number of services into count variable
        services.each do |s| #iterates over services
            checkLineItemsNumber "#{count}" #checks if correct number of services displayed
            removeService s.short #removes service
            count -= 1 #reduces expected number of services displayed by 1
        end

        services.each do |s|
            addService s.short #readd each service
        end

        checkLineItemsNumber "#{services.length}" #check if correct number of services displayed

        addAllServices(services)#adds all services in 'services' list a second time 
        checkLineItemsNumber "#{services.length}" #should still display same number of services

        find('.submit-request-button').click #submit request
        wait_for_javascript_to_finish
        ServiceRequest.find(1).line_items.count.should eq(services.length) #Should have correct # of services
    end


    def createNewStudy
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


        fill_in "study_short_title", :with => "Bob" #fill in short title
        find('.continue_button').click #click continue without Title, Funding Status, Sponsor Name
        wait_for_javascript_to_finish

            #should not display error div for field with info
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
            #should display error div with 3 errors
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")


        fill_in "study_title", :with => "Dole" #fill in title
        find('.continue_button').click #click continue without Funding Status, Sponsor Name
        wait_for_javascript_to_finish

            #should not display error div for filled in info
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
            #should display error div with 2 errors for missing info
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")


        fill_in "study_sponsor_name", :with => "Captain Kurt 'Hotdog' Zanzibar" #fill in sponsor name
        find('.continue_button').click #click continue without Funding Status
        wait_for_javascript_to_finish

            #should not display error divs for filled in info
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Short title')]")
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Title')]")
        page.should_not have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Sponsor name')]")
            #should display funding status missing error
        page.should have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'Funding status')]")


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

         
        select "Federal", :from => "study_funding_source" #select funding source

        find('.continue_button').click
        wait_for_javascript_to_finish
        #**END Create a new Study END**#     
    end


    def selectStudyUsers
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
    end 


    def enterProtocolDates
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
    end
  

    def readdServices(services = [])
        #expects list of ServiceWithAddress objects

        #Should have no services and instruct to add some
        page.should have_xpath("//div[@class='instructions' and contains(text(),'continue unless you have services in your cart.')]")
        click_link("Back to Catalog")

        #re-adds all services
        addAllServices(services)     

        find('.submit-request-button').click
        wait_for_javascript_to_finish
        click_link("Save & Continue")
        wait_for_javascript_to_finish        
    end


    def chooseArmPreferences(arms)
        #Expects a list of ASingleArm objects
        if arms.empty? then return end#If arms list is empty then end method here
            #edit Arm 1
        fill_in "study_arms_attributes_0_name", :with => arms[0].name
        fill_in "study_arms_attributes_0_subject_count", :with => arms[0].subjects # of subjects
        fill_in "study_arms_attributes_0_visit_count", :with => arms[0].visits # of visits
        wait_for_javascript_to_finish
            #edit rest of arms
        (1..arms.length-1).each do |i|
            click_link("Add Arm")
            wait_for_javascript_to_finish
            find(:xpath, "//div[@class='add-arm']/div[@class='fields'][last()]//input[contains(@name,'[name]')]").set(arms[i].name)
            find(:xpath, "//div[@class='add-arm']/div[@class='fields'][last()]//input[contains(@name,'[subject_count]')]").set(arms[i].subjects)
            find(:xpath, "//div[@class='add-arm']/div[@class='fields'][last()]//input[contains(@name,'[visit_count]')]").set(arms[i].visits)
            wait_for_javascript_to_finish
        end

        click_link("Save & Continue")
        wait_for_javascript_to_finish
    end

    class ASingleArm
        def initialize(options = {})
            defaults = {
                :name => "ARM",
                :subjects => 1,
                :visits => 5,
                :services => []
            }
            options = defaults.merge(options)
            @name = options[:name]
            @subjects = options[:subjects]
            @visits = options[:visits]
            @services = options[:services]
            @otfServices = []
            @ppServices = []

            @services.each do |service|
                service.subjects = @subjects
                if service.otf then @otfServices << service.clone
                else @ppServices << service.clone end
            end
        end

        attr_reader :name, :subjects, :visits, :services, :ppServices, :otfServices
    end

    def armTable(arm)
        find(:xpath, "//tr/th[contains(text(),'#{arm.name}')]/parent::tr/parent::tbody/parent::table")
    end

    def checkServiceVisit (arm, service, number)
        if number>arm.visits then return end #if number if greater than #vists, impossible, quit here
        column = (number%5)
        if column==0 then column=5 end
        armTable(arm).first(:xpath, "//select[@class='jump_to_visit']/option[contains(text(),'Visit #{number}')]").click
        # within armTable(arm) do select "Visit #{number}", :from => "jump_to_visit" end
        wait_for_javascript_to_finish
        box = armTable(arm).first(:xpath, "//tr/td[text()='#{service.name}']/parent::tr/td[@visit_column='#{column}']/input[@type='checkbox']")
        if not box.checked? then 
            box.click
            service.checked += 1
            wait_for_javascript_to_finish
        end
    end

    def setVisitDays(arm)
        #sets all visit days by incrementing from 1 up
        (0..(arm.visits-1)).each do |i|
            if i>0 and i%5==0 then #if all visit days are set in current view and 5 more need to be moved into view
                armTable(arm).first(:xpath, "//span[@class='ui-button-icon-primary ui-icon ui-icon-circle-arrow-e']").click
                wait_for_javascript_to_finish
            end
            armTable(arm).first(:xpath, "//th[@class='visit_number']/input[@id='day' and @data-position='#{i}']").set(i+1)
            wait_for_javascript_to_finish
        end
    end

    def checkStudyTotals(arm)
        #checks if study total is correct for each per patient service on arm
        clickOffAndWait
        arm.ppServices.each do |ppservice|
            expected = (ppservice.unitPrice * ppservice.checked * ppservice.subjects)
            total = find(:xpath, "//tr/th[contains(text(),'#{arm.name}')]/parent::tr/following-sibling::tr/td[text()='#{ppservice.name}']/parent::tr/td[contains(@class, 'pp_line_item_study_total')]").text[1..-1].to_f
            total.should eq(expected)
        end
    end

    def checkPPTotals(arm)
        #checks if per patient total is correct for each per patient service on arm
        clickOffAndWait
        arm.ppServices.each do |ppservice|
            expected = (ppservice.unitPrice * ppservice.checked * ppservice.subjects)
            total = find(:xpath, "//tr/th[contains(text(),'#{arm.name}')]/parent::tr/following-sibling::tr/td[text()='#{ppservice.name}']/parent::tr/td[contains(@class, 'pp_line_item_total')]").text[1..-1].to_f
            total.should eq(expected)
        end            
    end

    def checkTotals(arm)
        checkStudyTotals(arm)
        checkPPTotals(arm)
    end



    def completeVisitCalender(arms)
        #**Completing Visit Calender**#
            #save unit prices
        arms.each do |arm|
            setVisitDays(arm)
            checkTotals(arm)
            puts "before checkbox"
            checkServiceVisit(arm,arm.ppServices[0],2)
            puts "after checkbox"
            # sleep 120
        end

        sleep 600

        check('visits_1') #1st checkbox ARM 1
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        wait_for_javascript_to_finish
        totPerStudy = (arm1UnitPrice * 1 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
        find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * 1 * #patients)
        find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 1).round(2)) #ARM1 per patient total should eq (unitprice * 1)
        
        check('visits_4') #3rd checkbox ARM 1
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        wait_for_javascript_to_finish
        totPerStudy = (arm1UnitPrice * 2 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
        find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * 2 * #patients)
        find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 2).round(2)) #ARM1 per patient total should eq (unitprice * 2)
        
        check('visits_6') #5th checkbox ARM 1
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        wait_for_javascript_to_finish
        totPerStudy = (arm1UnitPrice * 3 * find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
        find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * 3 * #patients)
        find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm1UnitPrice * 3).round(2)) #ARM1 per patient total should eq (unitprice * 3)
        
            #set days in increasing order on ARM 2
        # find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_1']").set("1")
        # find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_2']").set("2")
        # find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_3']").set("3")
        # find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_4']").set("4")
        # find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_5']").set("5")
          
        check('visits_12') #2nd checkbox ARM 2
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        wait_for_javascript_to_finish
        totPerStudy = (arm2UnitPrice * 1 * find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
        find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM2 study total should eq (unitprice * 1 * #patients)
        find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq((arm2UnitPrice * 1).round(2)) #ARM2 per patient total should eq (unitprice * 1)

        check('visits_14') #4th checkbox ARM 2
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        wait_for_javascript_to_finish
        totPerStudy = (arm2UnitPrice * 2 * find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i).round(2)
        find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM2 study total should eq (unitprice * 2 * #patients)
        find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq((arm2UnitPrice * 2).round(2)) #ARM2 per patient total should eq (unitprice * 2)

        first(:xpath, "//input[@class='line_item_quantity']").set("3") #set CDW quantity to 3
        find(:xpath, "//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        find(:xpath, "//td[contains(@class,'otf_total total')]").text[1..-1].to_f.should eq((otfUnitPrice*3).round(2)) #otf total should eq (unitprice * 3)
        
            #**Switch to Quantity and Billing Tab**#
        click_link("Quantity/Billing Tab")
        wait_for_javascript_to_finish

            #check totals of ARM 1
        sumOfQuantities = 0
        [1,3,4,5,6].each do |n|
            sumOfQuantities += find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_#{n}_research_billing_qty']").value.to_i
        end
        wait_for_javascript_to_finish
        patientsNum = first(:xpath, "//div[@id='ui-tabs-2']//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i
        totPerStudy = (arm1UnitPrice * sumOfQuantities * patientsNum).round(2)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * sum of quantities * #patients)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm2UnitPrice * sumOfQuantities).round(2)) #ARM1 per patient total should eq (unitprice * sum of quantities)


        find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_3_research_billing_qty']").set(5)#change second visit research quantity to 5
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").click #click off input to refocus and recalculate
            #recheck totals of ARM 1 with second visit quantity now = 5
        sumOfQuantities = 0
        [1,3,4,5,6].each do |n|
            sumOfQuantities += find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_#{n}_research_billing_qty']").value.to_i
        end
        wait_for_javascript_to_finish
        patientsNum = first(:xpath, "//div[@id='ui-tabs-2']//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i
        totPerStudy = (arm1UnitPrice * sumOfQuantities * patientsNum).round(2)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * sum of quantities * #patients)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm2UnitPrice * sumOfQuantities).round(2)) #ARM1 per patient total should eq (unitprice * sum of quantities)    
        

        find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_4_insurance_billing_qty']").set(5)#change third visit insurance quantity to 5, should not change totals
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").click #click off input to refocus and recalculate
            #recheck totals of ARM 1 with third visit insurance quantity now = 5
        sumOfQuantities = 0
        [1,3,4,5,6].each do |n|
            sumOfQuantities += find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_#{n}_research_billing_qty']").value.to_i
        end
        wait_for_javascript_to_finish
        patientsNum = first(:xpath, "//div[@id='ui-tabs-2']//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i
        totPerStudy = (arm1UnitPrice * sumOfQuantities * patientsNum).round(2)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * sum of quantities * #patients)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm2UnitPrice * sumOfQuantities).round(2)) #ARM1 per patient total should eq (unitprice * sum of quantities)    


        find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_5_effort_billing_qty']").set(5)#change fourth visit effort quantity to 5, should not change totals
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").click #click off input to refocus and recalculate
            #recheck totals of ARM 1 with fourth visit effort quantity now = 5
        sumOfQuantities = 0
        [1,3,4,5,6].each do |n|
            sumOfQuantities += find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_#{n}_research_billing_qty']").value.to_i
        end
        wait_for_javascript_to_finish
        patientsNum = first(:xpath, "//div[@id='ui-tabs-2']//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i
        totPerStudy = (arm1UnitPrice * sumOfQuantities * patientsNum).round(2)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM1 study total should eq (unitprice * sum of quantities * #patients)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq((arm2UnitPrice * sumOfQuantities).round(2)) #ARM1 per patient total should eq (unitprice * sum of quantities)    

        find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_15_effort_billing_qty']").set(5)#change arm2 fifth visit effort quantity to 5, should not change totals
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_3_per_study']").click #click off input to refocus and recalculate
            #recheck totals of ARM 2 with fifth visit research quantity now = 5
        sumOfQuantities = 0
        [11,12,13,14,15].each do |n|
            sumOfQuantities += find(:xpath, "//div[@id='ui-tabs-2']//input[@id='visits_#{n}_research_billing_qty']").value.to_i
        end
        wait_for_javascript_to_finish
        patientsNum = first(:xpath, "//div[@id='ui-tabs-2']//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='subject_count']/select/option[@selected='selected']").text.to_i
        totPerStudy = (arm1UnitPrice * sumOfQuantities * patientsNum).round(2)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(totPerStudy) #ARM2 study total should eq (unitprice * sum of quantities * #patients)
        first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq((arm2UnitPrice * sumOfQuantities).round(2)) #ARM2 per patient total should eq (unitprice * sum of quantities)    

        first(:xpath, "//div[@id='ui-tabs-2']//input[@class='line_item_quantity']").set("6") #set CDW quantity to 6
        find(:xpath, "//div[@id='ui-tabs-2']//td[contains(@class,'otf_total total')]").click #allow to focus and recalculate
        find(:xpath, "//div[@id='ui-tabs-2']//td[contains(@class,'otf_total total')]").text[1..-1].to_f.should eq((otfUnitPrice*6).round(2)) #otf total should eq (unitprice * 6)


        arm1TotalPrice = first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f
        arm2TotalPrice = first(:xpath, "//div[@id='ui-tabs-2']//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f
        otfTotalPrice = find(:xpath, "//div[@id='ui-tabs-2']//td[contains(@class,'otf_total total')]").text[1..-1].to_f

        click_link("Save & Continue")
        wait_for_javascript_to_finish

        return [arm1TotalPrice,arm2TotalPrice,otfTotalPrice]
        #**END Completing Visit Calender ENDß**#     
         
    end


    def documentsPage()
        #**Documents page**#
        #sleep 2400
        #click_link("Add a New Document")
        #all('process_ssr_organization_ids_').each {|a| check(a)}
        #select "Other", :from => "doc_type"

        click_link("Save & Continue")
        wait_for_javascript_to_finish
        #**END Documents page END**#        
    end


    def reviewPage(arm1TotalPrice,arm2TotalPrice,otfTotalPrice)
        #**Review Page**#
            #Checking Totals... 
        # sleep 300
        first(:xpath, "//td[@class='total_1_per_study']").text[1..-1].to_f.should eq(arm1TotalPrice)
        first(:xpath, "//td[@class='total_3_per_study']").text[1..-1].to_f.should eq(arm2TotalPrice)
        first(:xpath, "//td[text()='MUSC Research Data Request (CDW)']/following-sibling::td[not(@colspan='6') and not(@class='your_cost')]").text[1..-1].to_f.should eq(otfTotalPrice)
        first(:xpath, "//td[@id='grand_total']").text[1..-1].to_f.should eq(arm1TotalPrice+arm2TotalPrice+otfTotalPrice)

        click_link("Submit to Start Services")
        wait_for_javascript_to_finish
        if have_xpath("//div[@aria-describedby='participate_in_survey' and @display!='none']") then
            first(:xpath, "//button/span[text()='No']").click
            wait_for_javascript_to_finish
        end
        #**END Review Page END**#        
    end


    def submissionConfirm()
        #**Submission Confirmation Page**#
        #sleep 2400
        click_link("Go to SPARC Request User Portal")
        wait_for_javascript_to_finish
        #**END Submission Confirmation Page END**#        
    end
    # end
end
