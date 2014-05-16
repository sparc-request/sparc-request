module CapybaraAdminPortal

    def goToAdminPortal
        #navigates to admin portal
        visit "/portal/admin"
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
        #expects instance of ServiceRequestForComparison as input 
        if not service.otf then return end #if service sent in was not one time fee, stop here.
        unitPrice = service.unitPrice
        fill_in "line_item_quantity", :with => quantity
        expectToastMessage
        waitAndClickOff
        expectedCost = (unitPrice*quantity).round(2)
        first(:xpath, "//div[@id='one_time_fee_table']/tbody/tr/td[contains(@id,'_cost')]").text[1..-1].to_f.should eq(expectedCost)
        wait_for_javascript_to_finish
    end

    def adminPortal(request)
        #expects instance of ServiceRequestForComparison as input 
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

        sleep 2400  
    end

end