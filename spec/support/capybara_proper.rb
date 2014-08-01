module CapybaraProper

    #******************************************************************#
    #####################vvvv NECESSARY CLASSES vvvv####################

    class ServiceRequestForComparison
        #intended as service request testing data structure for comparison with app's data structure
        #should organized arms, services, and study in somewhat the same manner as the app's.
        def initialize(services,arms,study)
            #expects a list of ServiceWithAddress objects,
            #a list of ASingleArm objects, and
            #an object of CustomStudy
            @services = services
            @arms = arms
            @study = study

            @otfServices = []
            @ppServices = []

            @services.each do |service|
                if service.otf then @otfServices << service
                else @ppServices << service.clone end
            end

            @arms.each do |arm|
                @ppServices.each do |service|
                    armService = service.clone
                    armService.subjects = arm.subjects
                    arm.services << armService
                end
            end

        end

        attr_accessor :services, :arms, :otfServices, :ppServices, :study
    end

    class ServiceWithAddress
        #intended as service testing data structure that also contains 
        # "address" of its core, program, provider, and institution
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
            @quantity = 0
            @subjects = 0
        end
        attr_reader :instit, :prov, :prog, :core, :name, :short, :otf, :unitPrice
        attr_accessor :totalPrice, :quantity, :subjects
    end

    class ASingleArm
        #Intended as arm testing data structure
        def initialize(options = {})
            defaults = {
                :name => "ARM",
                :subjects => 1,
                :visits => 5
            }
            options = defaults.merge(options)
            @name = options[:name]
            @subjects = options[:subjects]
            @visits = options[:visits]
            @services = []
            @totalPrice = 0
        end

        attr_reader :name, :subjects, :visits
        attr_accessor :services, :totalPrice
    end

    class CustomStudy
        #Intended as study testing data structure
        def initialize(options = {})
            defaults = {
                :short => "Study Short Title",
                :title => "Study Long Title",
                :fundingStatus => "Funded",
                :fundingSource => "Federal",
                :sponsorName => "Super Sponsor"
            }
            options = defaults.merge(options)
            @short = options[:short]
            @title = options[:title]
            @fundingStatus = options[:fundingStatus]
            @fundingSource = options[:fundingSource]
            @sponsorName = options[:sponsorName]
        end
        attr_accessor :short, :title, :fundingStatus, :sponsorName, :fundingSource
    end

#####################^^^^ NECESSARY CLASSES ^^^^####################
#******************************************************************#
#####################vvvv NECESSARY TOOLS vvvv######################



    def clickOffAndWait
        #allows javascript to complete
        #by clicking in a nonactive part of the page
        #then calls wait for javascript to finish method.
        first(:xpath, "//div[@class='welcome']").click
        wait_for_javascript_to_finish
    end    

    def saveAndContinue
        click_link("Save & Continue")
        wait_for_javascript_to_finish 
    end

    def clickContinueButton
        find('.continue_button').click
        wait_for_javascript_to_finish
    end

    def addService(serviceName)
        #if service is visible on screen,
        #clicks add button next to specified serviceName.
        #otherwise, searches for the service in the searchbox
        #and adds it from there
        #beware of services with a '(' in the name, capybara does 
        #not want to send that character in, thus causing
        #autocomplete of the searchbox to fail at times. 
        clickOffAndWait

        #ensure the correct service is selected, though portions of names of some services may be the same as others. 
        addServiceButton = first(:xpath, "//a[text()='#{serviceName}']/parent::span/parent::span//button[text()='Add']")
        if addServiceButton.nil? then 
            addServiceButton = first(:xpath, "//a[contains(text(),'#{serviceName}')]/parent::span/parent::span//button[text()='Add']")
        end

        if not addServiceButton.nil? then #if service is on screen then add it
            addServiceButton.click
            wait_for_javascript_to_finish
        else #else use the search box to find the service then add it
            wait_for_javascript_to_finish
            find(:xpath, "//input[@id='service_query']").set(serviceName)
            sleep 2
            response = first(:xpath, "//li[@class='search_result']/button[@class='add_service']")
            if response.nil? or not(response.visible?)
                sleep 3
                first(:xpath, "//li[@class='search_result']/button[@class='add_service']").click
            else response.click end
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
        # wait_until {first(:xpath, "//input[@id='line_item_count']")}['value'].should eq(numberExpected)
        assert_selector(:xpath, "//div[@class='line-items']/div[@class]", :count => numberExpected)
    end 


    def addAllServices(services)
        #expects list of ServiceWithAddress objects
        if services.empty? 
            return #if no services passed in, end method here.
        end

        services.each do |s| #iterates over services
            navigateCatalog(s.instit,s.prov,s.prog,s.core) #navigates to each service
            addService s.short #adds service
        end
        checkLineItemsNumber "#{services.length}" #check if correct number of services displayed
    end  


    def removeAllServices
        #finds all line item remove buttons and clicks them
        servicesLeft = all(:xpath, "//div[@class='line-items']/div[@class]").count
        # servicesLeft = find(:xpath, "//input[@id='line_item_count']")['value']
        while servicesLeft.to_i > 0 do
            first(:xpath, "//div[@class='line_item']//a[@class='remove-button']").click
            wait_for_javascript_to_finish
            servicesLeft = all(:xpath, "//div[@class='line-items']/div[@class]").count
            # servicesLeft = find(:xpath, "//input[@id='line_item_count']")['value']
        end
        checkLineItemsNumber '0'
    end

    def have_error_on(field)
        #expects a string describing the field the error is expected to be on
        #to be used in study creation pages that have the errorExplanation div
        have_xpath("//div[@id='errorExplanation']/ul/li[contains(text(),'#{field}')]")
    end

    def have_error_on_user_field(field)
        #expects a string describing the field the error is expected to be on
        #to be used in study creation pages that have the errorExplanation div
        have_xpath("//div[@id='error_explanation']/ul/li[contains(text(),'#{field}')]")
    end

    def removeUser(user)
        #expects a string with the name of the user desired to be removed
        #to be used on add users page in study creation
        find(:xpath, "//tr[contains(@class,'project_role')]/td[contains(text(),'#{user}')]/following-sibling::td/div/a[@class='remove_project_role']").click
        wait_for_javascript_to_finish
    end

    def clickUpdateUserButtonFor(user)
        #expects a string with the name of the user desired to be edited
        #to be used on add users page in study creation
        find(:xpath, "//tr[contains(@class,'project_role')]/td[contains(text(),'#{user}')]/following-sibling::td/div/a[@class='edit_project_role']").click
        wait_for_javascript_to_finish
    end

    def armTable(armName)
        #expects string of arm's name as input and a string describing tab
        #returns the table node element of the template tab in the service calendar
        tab = find(:xpath,"//div[contains(@id,'ui-tabs') and @aria-hidden='false']")#find tab that is currently displayed
        tab.find(:xpath, ".//table/tbody/tr/th[contains(text(),'#{armName}')]/parent::tr/parent::tbody/parent::table")
    end

    def moveVisitDayTo(armName,day,beforeWhere)
        clickOffAndWait
        armTable(armName).find(:xpath, ".//img[@src='/assets/sort.png']").click
        find(:xpath, "//select[contains(@id,'visit_to_move')]/option[text()='Visit #{day.to_s}']").select_option
        find(:xpath, "//select[contains(@id,'move_to_position')]/option[contains(text(),'Visit #{beforeWhere}')]").select_option
        click_button "submit_move"
        wait_for_javascript_to_finish
    end

    def testVisitDaysValidation(armName,numVisits)
        #expects browser to be on step 2b visit calendar for first time with no visit info filled in.
        saveAndContinue
        page.should have_error_on "study day for each visit" #Please specify a study day for each visit.
        if numVisits <3 then return end #if there are less than 3 visits, then ascending visit days validation can not be tested: quit here.
        
        table = armTable(armName)
        setVisitDays(armName, numVisits)
        #set visit days in descending order, should cause immediate error response
        table.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='0']").set(2)
        table.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='1']").set(1)
        saveAndContinue
        page.should have_error_on "Please make sure study days are in sequential order" 
        # first(:xpath, "//div[@class='welcome']").click #allows for refocus by clicking out of the input box
        # page.driver.browser.switch_to.alert.accept #accepts the error dialog box. will cause test to fail if no dialog appears.
        wait_for_javascript_to_finish

        table.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='1']").set(3)
        moveVisitDayTo(armName,1,3)
        #clear days
        table.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='0']").set("1")
        table.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='1']").set("2")
    end

    def setVisitDays(armName,numVisits)
        #expects string of arm's name,
        #and total number of visits on arm as input
        #sets all visit days by incrementing from 1 up
        currentArmTable = armTable(armName)
        (0..(numVisits-1)).each do |i|
            if i>0 and i%5==0 then #if all visit days are set in current view and 5 more need to be moved into view
                currentArmTable.first(:xpath, "./thead/tr/th/a/span[@class='ui-button-icon-primary ui-icon ui-icon-circle-arrow-e']").click
                wait_for_javascript_to_finish
            end
            currentArmTable.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@id='day' and @data-position='#{i}']").set(i+1)
            wait_for_javascript_to_finish
        end
        #bring first visit set back into view
        while !(currentArmTable.first(:xpath, "./thead/tr/th/a/span[@class='ui-button-icon-primary ui-icon ui-icon-circle-arrow-w']", :visible => true).nil?)
            currentArmTable.first(:xpath, "./thead/tr/th/a/span[@class='ui-button-icon-primary ui-icon ui-icon-circle-arrow-w']", :visible => true).click
            wait_for_javascript_to_finish
        end
    end

    def checkStudyTotal(armName, serviceName, expected)
        #expects string of arm's name, serviceName, and expected total as input
        #checks if study total is correct for specified per patient service on arm
        clickOffAndWait
        currentArmTable = armTable(armName)
        total = currentArmTable.find(:xpath, "./tbody/tr/td[contains(text(),'#{serviceName}')]/parent::tr/td[contains(@class, 'pp_line_item_study_total')]").text[1..-1].to_f
        total.should eq(expected)
    end

    def checkPPTotal(armName, serviceName, expected)
        #expects string of arm's name, serviceName, and expected total as input
        #checks if per patient total is correct for specified per patient service on arm
        clickOffAndWait
        currentArmTable = armTable(armName)
        total = currentArmTable.find(:xpath, "./tbody/tr/td[contains(text(),'#{serviceName}')]/parent::tr/td[contains(@class, 'pp_line_item_total')]").text[1..-1].to_f
        total.should eq(expected)          
    end     

    def checkArmTotals(arm)
        #expects instance of ASingleArm as input
        #checks the arm totals are correct in the template tab of the service calendar
        total = 0
        arm.services.each do |service|

            expectedStudyTotal = (service.unitPrice/2 * service.quantity * service.subjects).round(2)
            checkStudyTotal(arm.name,service.name,expectedStudyTotal)
            service.totalPrice = expectedStudyTotal
            total += expectedStudyTotal

            expectedPPTotal = (service.unitPrice/2 * service.quantity).round(2)
            checkPPTotal(arm.name,service.name,expectedPPTotal)

        end
        arm.totalPrice = total
    end

    def checkOTFTotal(service)
        #expects instance of ServiceWithAddress as input
        #checks if total is correct for specified otf service
        clickOffAndWait
        currentArmTable = armTable("Other Services")
        quantity = currentArmTable.first(:xpath, "./tbody/tr/td[contains(text(),'#{service.name}')]/parent::tr/td/input[@class='line_item_quantity']")['value'].to_i
        yourCost = currentArmTable.first(:xpath, "./tbody/tr/td[@class='your_cost']").text[1..-1].to_f
        otfExpected = (yourCost * quantity).round(2)
        total = currentArmTable.find(:xpath, "./tbody/tr/td[contains(text(),'#{service.name}')]/parent::tr/td[contains(@class, 'otf_total')]").text[1..-1].to_f
        total.should eq(otfExpected)
        service.totalPrice = otfExpected

        # end            
    end   

    def checkTotals(serviceRequestFC)
        #for entire service request, checks 
        #both pp services and otf services for correct totals.
        serviceRequestFC.arms.each do |arm|
            checkArmTotals(arm)
        end
        serviceRequestFC.otfServices.each do |service|
            checkOTFTotal(service)
        end
    end

    def markServiceVisit (arm, serviceName, visitNumber)
        #expects instance of ASingleArm,
        #instance of ServiceWithAddress,
        #and visit number desired to be marked for input.
        #checks a checkbox in the template tab of the service calendar
        if visitNumber>arm.visits or visitNumber<=0 then return end #if number is greater than #vists, impossible, quit here
        
        armService = nil
        arm.services.each do |service|
            if service.name == serviceName then 
                armService=service
                break
            end
        end
        if armService.nil? then return end #if arm does not have service desired, impossible, quit here

        column = (visitNumber%5)
        if column==0 then column=5 end
        currentArmTable = armTable(arm.name)

        visitInView = currentArmTable.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@class='visit_name' and @value='Visit #{visitNumber}']")
        if visitInView.nil? then
            currentArmTable.find(:xpath, "./thead/tr/th/select[@class='jump_to_visit']/option[contains(text(),'Visit #{visitNumber}')]").click
            wait_for_javascript_to_finish
        end

        box = currentArmTable.find(:xpath, "./tbody/tr/td[text()='#{serviceName}']/parent::tr/td[@visit_column='#{column}']/input[@type='checkbox']")
        if not box.checked? then 
            box.click
            armService.quantity += 1 #in order to keep correct quantity count,
            #the service object passed in must be the object kept in the arm's services list
            wait_for_javascript_to_finish
        end
    end

    def changeResearchBillingQty (arm, serviceName, visitNumber, qty)
        #expects instance of ASingleArm,
        #instance of ServiceWithAddress,
        #visit number desired to be changed to qty.
        #Changes the research quantity number on a visit in the Quantity and Billing tab
        if visitNumber>arm.visits or visitNumber<=0 then return end #if visitNumber is greater than #vists, impossible, quit here
        
        armService = nil
        arm.services.each do |service|
            if service.name == serviceName then 
                armService=service
                break
            end
        end
        if armService.nil? then return end #if arm does not have service desired, impossible, quit here

        column = (visitNumber%5)
        if column==0 then column=5 end
        currentArmTable = armTable(arm.name)

        visitInView = currentArmTable.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@class='visit_name' and value='Visit #{visitNumber}']")
        if visitInView.nil? then
            currentArmTable.find(:xpath, "./thead/tr/th/select[@class='jump_to_visit']/option[contains(text(),'Visit #{visitNumber}')]").click
            wait_for_javascript_to_finish
        end

        box = currentArmTable.find(:xpath, "./tbody/tr/td[text()='#{serviceName}']/parent::tr/td[@visit_column='#{column}']/input[contains(@id,'research_billing_qty')]")
        currentQuantity = box.value.to_i
        box.set(qty)
        armService.quantity += (qty-currentQuantity) #in order to keep correct quantity count,
        #the service object passed in must be the object kept in the arm's services list
        wait_for_javascript_to_finish
    end

    def changeInsuranceBillingQty (arm, serviceName, visitNumber, qty)
        #expects instance of ASingleArm,
        #instance of ServiceWithAddress,
        #visit number desired to be changed of quantity.
        #Changes the insurance quantity number on a visit in the Quantity and Billing tab
        if visitNumber>arm.visits or visitNumber<=0 then return end #if visitNumber is greater than #vists, impossible, quit here
        
        armService = nil
        arm.services.each do |service|
            if service.name == serviceName then 
                armService=service
                break
            end
        end
        if armService.nil? then return end #if arm does not have service desired, impossible, quit here

        column = (visitNumber%5)
        if column==0 then column=5 end
        currentArmTable = armTable(arm.name)

        visitInView = currentArmTable.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@class='visit_name' and value='Visit #{visitNumber}']")
        if visitInView.nil? then
            currentArmTable.find(:xpath, "./thead/tr/th/select[@class='jump_to_visit']/option[contains(text(),'Visit #{visitNumber}')]").click
            wait_for_javascript_to_finish
        end

        currentArmTable.find(:xpath, "./tbody/tr/td[text()='#{serviceName}']/parent::tr/td[@visit_column='#{column}']/input[contains(@id,'insurance_billing_qty')]").set(qty)
        wait_for_javascript_to_finish
    end

    def changeEffortBillingQty (arm, serviceName, visitNumber, qty)
        #expects instance of ASingleArm,
        #instance of ServiceWithAddress,
        #visit number desired to be changed of quantity.
        #Changes the effort quantity number on a visit in the Quantity and Billing tab
        if visitNumber>arm.visits or visitNumber<=0 then return end #if visitNumber is greater than #vists, impossible, quit here
        
        armService = nil
        arm.services.each do |service|
            if service.name == serviceName then 
                armService=service
                break
            end
        end
        if armService.nil? then return end #if arm does not have service desired, impossible, quit here

        column = (visitNumber%5)
        if column==0 then column=5 end
        currentArmTable = armTable(arm.name)

        visitInView = currentArmTable.first(:xpath, "./thead/tr/th[@class='visit_number']/input[@class='visit_name' and value='Visit #{visitNumber}']")
        if visitInView.nil? then
            currentArmTable.find(:xpath, "./thead/tr/th/select[@class='jump_to_visit']/option[contains(text(),'Visit #{visitNumber}')]").click
            wait_for_javascript_to_finish
        end

        wait_for_javascript_to_finish
        currentArmTable.find(:xpath, "./tbody/tr/td[text()='#{serviceName}']/parent::tr/td[@visit_column='#{column}']/input[contains(@id,'effort_billing_qty')]").set(qty)
        wait_for_javascript_to_finish
    end

    def setOTFQuantity (serviceName, quantity) 
        #changes the quantity for the specified OTF service
        #in the template tab of the service calendar
        currentArmTable = armTable("Other Services")
        currentArmTable.first(:xpath, "./tbody/tr/td[contains(text(),'#{serviceName}')]/parent::tr/td/input[@class='line_item_quantity']").set(quantity)
    end

    def checkReviewTotals(request)
        #expects instance of ServiceRequestForComparison as input 
        grandTotal = 0
        calendarContainer = first(:xpath,"//div[@id='service_calendar_container']")
        request.arms.each do |arm|
            armTab = calendarContainer.first(:xpath,"./table/tbody/tr/th[contains(text(),'#{arm.name}')]/parent::tr/parent::tbody/parent::table")
            arm.services.each do |service|
                reflectedTotal = armTab.first(:xpath,"./tbody/tr[@class='line_item']/td[contains(@class,'per_study')]").text[1..-1].to_f
                reflectedTotal.should eq(service.totalPrice)
                grandTotal += reflectedTotal
            end
        end
        request.otfServices.each do |otfservice|
            table = calendarContainer.first(:xpath,"./table/tbody/tr/th[contains(text(),'Other Services')]/parent::tr/parent::tbody/parent::table")
            reflectedTotal = table.first(:xpath,"./tbody/tr[@class='line_item']/td[not(@class) and contains(text(),'$')]").text[1..-1].to_f
            reflectedTotal.should eq(otfservice.totalPrice)
            grandTotal += reflectedTotal
        end
        first(:xpath, "//td[@id='grand_total']").text[1..-1].to_f.should eq(grandTotal)        
    end

    #####################^^^^ NECESSARY TOOLS ^^^^######################
    #******************************************************************#
    ##################vvvv NECESSARY COMPONENTS vvvv####################

    def createNewStudy(request)
        #expects instance of ServiceRequestForComparison as input 
        study = request.study

        click_link("New Study")
        wait_for_javascript_to_finish

        clickContinueButton #click continue with no form info

        #should display error div with 4 errors
        page.should have_error_on "Short title"
        page.should have_error_on "Title"
        page.should have_error_on "Funding status"
        page.should have_error_on "Sponsor name"

        fill_in "study_short_title", :with => study.short #fill in short title
        clickContinueButton #click continue without Title, Funding Status, Sponsor Name

        #should not display error div for field with info
        page.should_not have_error_on "Short title"
        #should display error div with 3 errors
        page.should have_error_on "Title"
        page.should have_error_on "Funding status"
        page.should have_error_on "Sponsor name"

        fill_in "study_title", :with => study.title #fill in title
        clickContinueButton #click continue without Funding Status, Sponsor Name

        #should not display error div for filled in info
        page.should_not have_error_on "Short title"
        page.should_not have_error_on "Title"
        #should display error div with 2 errors for missing info
        page.should have_error_on "Funding status"
        page.should have_error_on "Sponsor name"

        fill_in "study_sponsor_name", :with => study.sponsorName #fill in sponsor name
        clickContinueButton #click continue without Funding Status

        #should not display error divs for filled in info
        page.should_not have_error_on "Short title"
        page.should_not have_error_on "Title"
        page.should_not have_error_on "Sponsor name"
        #should display funding status missing error
        page.should have_error_on "Funding status"

        select study.fundingStatus, :from => "study_funding_status" #select funding status
        clickContinueButton #click continue without Funding Source  

        #should not display error divs for filled in info
        page.should_not have_error_on "Short title"
        page.should_not have_error_on "Title"
        page.should_not have_error_on "Sponsor name"
        page.should_not have_error_on "Funding status"
        #should display funding source missing error
        page.should have_error_on "Funding source"
         
        select study.fundingSource, :from => "study_funding_source" #select funding source
        clickContinueButton
    end

    def createNewProject(request)
        #expects instance of ServiceRequestForComparison as input 
        project = request.study

        find('input#protocol_Research_Project').click
        wait_for_javascript_to_finish

        find('a.new-project').click
        wait_for_javascript_to_finish

        clickContinueButton #click continue with no form info

        #should display error div with 3 errors
        page.should have_error_on "Short title"
        page.should have_error_on "Title"
        page.should have_error_on "Funding status"

        fill_in "project_short_title", :with => 'Carl' #fill in short title
        clickContinueButton #click continue without Title, Funding Status, Sponsor Name

        #should not display error div for field with info
        page.should_not have_error_on "Short title"
        #should display error div with 2 errors
        page.should have_error_on "Title"
        page.should have_error_on "Funding status"

        fill_in "project_title", :with => project.title+'2' #fill in title
        clickContinueButton #click continue without Funding Status, Sponsor Name

        #should not display error div for filled in info
        page.should_not have_error_on "Short title"
        page.should_not have_error_on "Title"
        #should display error div with 1 error for missing info
        page.should have_error_on "Funding status"

        select project.fundingStatus, :from => "project_funding_status" #select funding status
        clickContinueButton #click continue without Funding Source  

        #should not display error divs for filled in info
        page.should_not have_error_on "Short title"
        page.should_not have_error_on "Title"
        page.should_not have_error_on "Funding status"
        #should display funding source missing error
        page.should have_error_on "Funding source"
         
        select project.fundingSource, :from => "project_funding_source" #select funding source
        clickContinueButton
        selectStudyUsers
        find('input#protocol_Research_Study').click
        wait_for_javascript_to_finish
    end

    def editEpicUserAccess
        find(:xpath, "//a[@class='epic_access_edit']").click
        wait_for_javascript_to_finish
    end

    def selectStudyUsers
        clickContinueButton #click continue with no users added
        wait_for_javascript_to_finish
        page.should have_error_on "must add yourself" #You must add yourself as an authorized user
        page.should have_error_on "Primary PI" #You must add a Primary PI to the study/project

        click_button "Add Authorized User" #add the user without a role
        wait_for_javascript_to_finish
        #should have 'Role can't be blank' error
        page.should have_xpath("//div[@id='user_detail_errors']/ul/li[contains(text(),'Role can')]")
        page.should have_xpath("//div[@class='field_with_errors']/label[text()='Role:*']")

        select "Primary PI", :from => "project_role_role"
        click_button "Add Authorized User"
        wait_for_javascript_to_finish

        fill_in "user_search_term", :with => "bjk7"
        wait_for_javascript_to_finish
        sleep 4
        response = find('a', :text => "Brian Kelsey (kelsey@musc.edu)")
        if response.nil? or not(response.visible?)
            wait_for_javascript_to_finish
            find('a', :text => "Brian Kelsey (kelsey@musc.edu)").click
        else response.click end
        wait_for_javascript_to_finish

        click_button "Add Authorized User" #add the user without a role
        wait_for_javascript_to_finish
        #should have 'Role can't be blank' error
        page.should have_xpath("//div[@id='user_detail_errors']/ul/li[contains(text(),'Role can')]")
        page.should have_xpath("//div[@class='field_with_errors']/label[text()='Role:*']")

        select "Primary PI", :from => "project_role_role"
        click_button "Add Authorized User" #Add second Primary PI
        wait_for_javascript_to_finish

        clickContinueButton
        page.should have_error_on "Primary PI" #should reject multiple Primary PIs

        clickUpdateUserButtonFor "Brian Kelsey"
        select "Other", :from => "project_role_role" #set role to other
        fill_in "project_role_role_other", :with => "Primary PI" #set name of other role to Primary PI
        click_button "Update Authorized User"

        clickUpdateUserButtonFor "Brian Kelsey"
        select "Billing/Business Manager", :from => "project_role_role"
        click_button "Update Authorized User"
        wait_for_javascript_to_finish

        clickContinueButton
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

    def completeTemplateTab(request)
        #expects instance of ServiceRequestForComparison as input
        #tests the template tab of the service calendar
        #checks the totals of
        checkTotals(request)
        testVisitDaysValidation(request.arms[0].name,request.arms[0].visits)
        request.arms.each do |arm|
            setVisitDays(arm.name,arm.visits)
            markServiceVisit(arm,arm.services[0].name,2)
            markServiceVisit(arm,arm.services[0].name,3)
            markServiceVisit(arm,arm.services[0].name,5)
            markServiceVisit(arm,arm.services[0].name,7)
            checkArmTotals(arm)
        end
        request.otfServices.each do |otfservice|
            setOTFQuantity(otfservice.name,5)
            checkOTFTotal(otfservice)
        end
        checkTotals(request)
    end

    def switchToBillingTab
        click_link("Quantity/Billing Tab")
        wait_for_javascript_to_finish
    end
    
    def completeQuantityBillingTab(request)
        #expects instance of ServiceRequestForComparison as input
        #tests the quantity and billing tab of the service calendar
        
        checkTotals(request)

        request.arms.each do |arm|#set 1st visit research qty of all services on all arms to 3
            arm.services.each do |service|
                changeResearchBillingQty(arm, service.name, 1, 3)
            end
        end
        checkTotals(request)
        
        request.arms.each do |arm|#set 1st visit insurance qty of all services on all arms to 5
            arm.services.each do |service|
                changeInsuranceBillingQty(arm, service.name, 1, 5)
            end
        end
        checkTotals(request)

        request.arms.each do |arm|#set 1st visit effort qty of all services on all arms to 8
            arm.services.each do |service|
                changeEffortBillingQty(arm, service.name, 1, 8)
            end
        end
        checkTotals(request)

        request.otfServices.each do |otfservice|#set all otf service quantities to 6
            setOTFQuantity(otfservice.name,6)
            checkOTFTotal(otfservice)
        end
        checkTotals(request)
    end

    def askAQuestionTest
        #tests the "Ask A Question" button on the sparc proper catalog page
        def assertFormVisible
            assert_selector('#ask-a-question-form')
        end
        find('.ask-a-question-button').click
        wait_for_javascript_to_finish
        assert_selector('#ask-a-question-form', :visible => true)
        find('#submit_question').click
        wait_for_javascript_to_finish
        assert_selector('#ask-a-question-form', :visible => true)
        page.should have_content("Valid email address required.")

        find('#quick_question_email').set('Pappy')
        find('#submit_question').click
        wait_for_javascript_to_finish
        assert_selector('#ask-a-question-form', :visible => true)
        page.should have_content("Valid email address required.")

        find('#quick_question_email').set('juan@gmail.com')
        find('#submit_question').click
        wait_for_javascript_to_finish
        assert_no_selector('#ask-a-question-form', :visible => true)
    end

    def feedbackTest
        #tests the "Feedback" button on the sparc proper catalog page
        find('.feedback-button').click
        wait_for_javascript_to_finish
        assert_selector('#feedback-form', :visible => true)
        find('#submit_feedback').click
        wait_for_javascript_to_finish
        find('#error-text').text.should eq("Message can't be blank")

        within("#feedback-form") do
          fill_in 'feedback_message', :with => "Testing 123"
          wait_for_javascript_to_finish
        end
        find('#submit_feedback').click
        wait_for_javascript_to_finish
        assert_no_selector('#feedback-form', :visible => true)
    end

    def helpTest
        #tests the "Help" button on the sparc proper catalog page
        find('.faq-button').click
        wait_for_javascript_to_finish
        assert_selector(:xpath, "//span[@class='help_question']", :visible => true)
        first(:xpath, "//span[@class='help_question']").click
        wait_for_javascript_to_finish
        assert_selector(:xpath, "//span[@class='help_answer']", :visible => true)
        find('.qtip-button').click
        wait_for_javascript_to_finish
    end

    def login(un,pwd)
        #logs the user in the custom username and password.
        currentUrl = page.current_url
        visit "/identities/sign_in"
        wait_for_javascript_to_finish
        loginDiv = first(:xpath,"//div[@id='login']")
        if loginDiv.nil? then 
            if not currentUrl==page.current_url then visit "#{currentUrl}" end
            wait_for_javascript_to_finish
            return #if the login dialog is not displayed quit here.
        end 
        click_link "Outside Users Click Here"
        wait_for_javascript_to_finish
        fill_in "identity_ldap_uid", :with => un
        fill_in "identity_password", :with => pwd
        first(:xpath, "//input[@type='submit' and @value='Sign In']").click
        wait_for_javascript_to_finish
    end

    def newUserTest
        #tests the "Create an Account" button on the sparc proper catalog page
        click_link "logout"
        wait_for_javascript_to_finish
        find(:xpath, "//div[@class='create_new_account']/a").click
        wait_for_javascript_to_finish
        currentBox = find(:xpath, "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;') and not(@id)]")
        within currentBox do 
            find(:xpath, ".//input[@value='Create New User']").click
            wait_for_javascript_to_finish
            page.should have_error_on_user_field "Password"
            page.should have_error_on_user_field "Ldap uid"
            page.should have_error_on_user_field "First name"
            page.should have_error_on_user_field "Last name"
            sleep 2

            fill_in 'identity_last_name', :with => 'Jingleheimerschmidt'
            wait_for_javascript_to_finish
            fill_in 'identity_first_name', :with => 'John'
            wait_for_javascript_to_finish
            fill_in 'identity_ldap_uid', :with => 'JJJ123'
            wait_for_javascript_to_finish
            fill_in 'identity_password', :with => 'Jacob'
            wait_for_javascript_to_finish
            find(:xpath, ".//input[@value='Create New User']").click
            wait_for_javascript_to_finish
            page.should have_error_on_user_field "confirmation"
            page.should have_error_on_user_field "short"
            wait_for_javascript_to_finish

            fill_in 'identity_password', :with => 'Jacob1'
            wait_for_javascript_to_finish
            fill_in 'identity_password_confirmation', :with => 'Jacob1'
            wait_for_javascript_to_finish
            find(:xpath, ".//input[@value='Create New User']").click
            wait_for_javascript_to_finish
            wait_for_javascript_to_finish
            page.should have_content "New account created"
        end

        click_link "Close Window"
        wait_for_javascript_to_finish
        login("jug2", "p4ssword")
    end

    def aboutSparcTest
        #tests the "About SPARC Request" button on the sparc proper catalog page
        find('a.about_sparc_request').click
        wait_for_javascript_to_finish
        page.should have_content "is a web-based research management system that provides a central portal"
        find(:xpath, "//span[text()='About SPARC Request']/following-sibling::button[@title='close']").click
        wait_for_javascript_to_finish
    end


    ##################^^^^ NECESSARY COMPONENTS ^^^^####################
    #******************************************************************#
    ###################vvvv NECESSARY SCRIPTS vvvv######################

    def submitServiceRequestPage (request)
        #expects instance of ServiceRequestForComparison as input 
        submitExpectError #checks submit with no services error display

        aboutSparcTest
        askAQuestionTest
        feedbackTest
        helpTest
        newUserTest

        services = request.services
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
    end

    def selectStudyPage(request)
        #expects instance of ServiceRequestForComparison as input 

        page.should_not have_xpath("//div[@id='errorExplanation']")#should not have any errors displayed
        saveAndContinue #click continue without study/project selected
        page.should have_error_on "You must identify the service request with a study/project before continuing."
        
        createNewProject(request)

        createNewStudy(request)
        selectStudyUsers

        removeAllServices

        saveAndContinue  
        wait_for_javascript_to_finish
        #Should have no services and instruct to add some
        page.should have_error_on 'Your cart is empty.'
        click_link("Back to Catalog")
        addAllServices(request.services) #re-adds all services   
        find('.submit-request-button').click #submit service request and go to Select Study page
        wait_for_javascript_to_finish
        saveAndContinue #Continue past select study page
    end

    def selectDatesAndArmsPage(request)
        #expects instance of ServiceRequestForComparison as input 

        saveAndContinue #save and continue with no start or end date
        page.should have_error_on "start date" #should complain about not having a start date
        page.should have_error_on "end date" #should complain about not having an end date

        enterProtocolDates

        chooseArmPreferences(request.arms)
        saveAndContinue
    end

    def serviceCalendarPage(request)
        #expects instance of ServiceRequestForComparison as input 
        completeTemplateTab(request)

        switchToBillingTab
        completeQuantityBillingTab(request)

        saveAndContinue   
    end

    def documentsPage
        click_link "Add a New Document"
        file = Tempfile.new 'doc'
        first(:xpath,"//input[@id='document']").set(file.path)
        select "Other", :from => "doc_type"
        first(:xpath,"//input[@id='process_ssr_organization_ids_']").click
        click_link "Upload"
        wait_for_javascript_to_finish
        click_link "Edit"
        wait_for_javascript_to_finish
        click_link "Update"
        wait_for_javascript_to_finish
        file.unlink
        saveAndContinue      
    end

    def reviewPage(request)
        #expects instance of ServiceRequestForComparison as input 
        checkReviewTotals(request)
        click_link("Submit to Start Services")
        wait_for_javascript_to_finish
        if have_xpath("//div[@aria-describedby='participate_in_survey' and @display!='none']") then
            first(:xpath, "//button/span[text()='No']").click
            wait_for_javascript_to_finish
        end   
    end


    def submissionConfirmationPage
        click_link("Go to SPARC Request User Portal")
        wait_for_javascript_to_finish
    end


    ###################^^^^ NECESSARY SCRIPTS ^^^^######################
    #******************************************************************#

end
