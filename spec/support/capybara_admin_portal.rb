module CapybaraAdminPortal

    def goToSparcProper
        visit root_path
        wait_for_javascript_to_finish
        if have_xpath("//div[@class='welcome']/span[text()='Not Logged In']") then
            login("jug2@musc.edu","password")
        end
    end

    def goToAdminPortal
        #navigates to admin portal
        visit "/portal/admin"
        wait_for_javascript_to_finish
    end

    def login(un,pwd)
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

    def waitAndClickOff
        #allows javascript to complete
        #by clicking in a nonactive part of the page
        #then calls wait for javascript to finish method.
        #equivalent of clickOffAndWait in CapybaraProper, 
        #however a different part of the page is clicked as
        #the CapybaraProper xpath is unavailable in the Admin Portal.
        first(:xpath, "//div[@id='welcome_msg']/span").click
        wait_for_javascript_to_finish
    end    

    def enterServiceRequest(studyShortName, serviceName)
        #clicks on a specific row in the admin portal display table
        find(:xpath, "//table[@id='admin-tablesorter']/tbody/tr/td/ul/span[text()='#{serviceName}']/ancestor::tr/td[text()='#{studyShortName}']").click
    end

    def expectToastMessage
        #checks for presence of toast message
        page.should have_xpath("//div[@class='toast-item-wrapper']")
    end

    def expectStatusChangeRecord(changedFrom, changedTo)
        #checks for presence of record in Status Changes table
        page.should have_xpath("//table[@id='status_history_table']/tbody/tr/td[2][text()='#{changedFrom}']/following-sibling::td[text()='#{changedTo}']")
    end

    def addNote(text)
        #adds a new note and checks that the note was added
        fill_in "notes", :with => text
        click_link "Add Note"
        page.should have_xpath("//div[@class='note_body' and text()='#{text}']")
    end

    def testSubsidy(percentage)
        #expects a number between 0 and 100
        #changes the % Subsidy field and checks that 
        #the page reflects the change
        click_link "Add a Subsidy"
        wait_for_javascript_to_finish

        currentCost = first(:xpath, "//td[@class='effective_cost']").text[1..-1].to_f
        userDisplayCost = first(:xpath, "//td[@class='display_cost']").text[1..-1].to_f
        piContribution = (currentCost-((currentCost*percentage)/100)).round(2)
        subCurrentCost = ((currentCost*percentage)/100).round(2)
        subDisplayCost = ((userDisplayCost*percentage)/100).round(2)

        fill_in "subsidy_percent_subsidy", :with => "#{percentage}"
        waitAndClickOff

        find(:xpath, "//input[@id='subsidy_pi_contribution']")['value'].to_f.should eq(piContribution)
        find(:xpath, "//td[@class='subsidy_effective_current_cost']").text[1..-1].to_f.should eq(subCurrentCost)
        find(:xpath, "//td[@class='subsidy_user_display_cost']").text[1..-1].to_f.should eq(subDisplayCost)

        find(:xpath, "//div[@id='subsidy_table']//a[@class='delete_data']/img[@alt='Cancel']").click
        wait_for_javascript_to_finish
    end

    def testOTFService(service,quantity)
        #expects instance of ServiceWithAddress, and integer quantity as input
        #quantity will round down if not integer and will be input to service quantity box.
        #the cost will then 
        if not service.otf then return end #if service sent in was not one time fee, stop here.
        unitPrice = service.unitPrice
        fill_in "line_item_quantity", :with => quantity
        expectToastMessage
        waitAndClickOff
        quantity = quantity.floor
        expectedCost = (unitPrice/2*quantity).round(2) #divided by 2 here because the effective percentage is 50
        #this makes this method only effective for the SR of the happy_test suite until effective percentage is
        #pulled out from either the SR or service. 
        first(:xpath, "//div[@id='one_time_fee_table']/table/tbody/tr/td[contains(@id,'_cost')]").text[1..-1].to_f.should eq(expectedCost)
        wait_for_javascript_to_finish
    end

    def adminPortal(request)
        #expects instance of ServiceRequestForComparison as input 
        goToSparcProper
        puts 'sp over'
        sleep 600
        goToAdminPortal
        enterServiceRequest(request.study.short,request.services[0].name)

        select "Get a Quote", :from => "sub_service_request_status"
        expectToastMessage
        select "Submitted", :from => "sub_service_request_status"
        expectToastMessage
        expectStatusChangeRecord("Get a Quote","Submitted")

        addNote ("This is a Note")
        testSubsidy(50)
        testSubsidy(30)
        testSubsidy(20)

        testOTFService(request.services[0],20)
        testOTFService(request.services[0],3)
        testOTFService(request.services[0],request.services[0].quantity)

        # sleep 2400  
    end

end