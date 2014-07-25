module CapybaraClinical
    include CapybaraAdminPortal

    def goToCWF
        #navigates to clinical work fulfillment home
        visit "/clinical_work_fulfillment"
        wait_for_javascript_to_finish
    end

    def upperInputTest
        ##routing##
        fill_in 'ssr_routing', :with => 'HWY 17S'
        find(:xpath, "//a[@id='ssr_save']/span[text()='Save']").click
        wait_for_javascript_to_finish
        page.should have_xpath "//span[@class='routing_message icon check']"
        ##billing/business manager##
        fill_in 'protocol_billing_business_manager_static_email', :with => 'elhombre@thefeds.gov'
        find(:xpath, "//a[@id='protocol_billing_business_manager_static_email_save']/span[text()='Save']").click
        wait_for_javascript_to_finish
        page.should have_xpath "//span[@class='billing_business_message icon check']"
    end

    def testService(service)
        #expects instance of ServiceWithAddress as input
        #adds a visit then deletes the same visit in the visit calendar
        switchTabTo "Study Schedule"
        upperInputTest
        visitText = find(:xpath, "//select[@id='visit_position']/option[@value='']").text[4..-1]
        visitDay = visitText[6..-1]
        find(:xpath, "//a[@class='add_visit_link']").click
        currentBox = first(:xpath, "//div[contains(@class,'ui-dialog ') and contains(@style,'display: block;')]")
        within currentBox do
            fill_in 'visit_name', :with => visitText
            fill_in 'visit_day', :with => visitDay
            find(:xpath, ".//button/span[text()='Submit']").click
            wait_for_javascript_to_finish
        end

        select "Delete #{visitText} - #{visitText}", :from => 'delete_visit_position'
        find(:xpath, "//a[@class='delete_visit_link']").click
        wait_for_javascript_to_finish
    end

    def check_subject_tracker_totals(service)
        #expects instance of ServiceWithAddress as input
        #meant to be ran on the subject tracker page where 
        #the service passed in is in view and available
        completedBox = find(:xpath, "//div[@aria-hidden='false']//td[text()='#{service.name}']/following-sibling::td[contains(@class, 'check_box_cell')]/input[@type='checkbox']")
        unit = find(:xpath, "//div[@aria-hidden='false']//td[text()='#{service.name}']/following-sibling::td[contains(@class,'unit_cost_cell')]").text[1..-1].to_f
        rQuantity = find(:xpath, "//div[@aria-hidden='false']//td[text()='#{service.name}']/following-sibling::td[contains(@class, 'r_qty_cell')]/input")['value'].to_f
        actualTotal = find(:xpath, "//div[@aria-hidden='false']//td[text()='#{service.name}']/following-sibling::td[contains(@class, 'procedure_total_cell')]").text[1..-1].to_f

        expectedTotal = completedBox.checked? ? unit*rQuantity : 0.0
        actualTotal.should eq(expectedTotal)
    end        

    def save_validation_check
        #will check if save warning occurs
        #then save the page
        #then make sure save warning disappears.
        page.should have_content "You must save this form for any changes to be commited."
        find("#save_appointments").click
        wait_for_javascript_to_finish
        page.should_not have_content "You must save this form for any changes to be commited."
    end

    def subjectVisitCalendarTest(subjectName, service)
        #expects string of subject's name as input
        #expects instance of ServiceWithAddress as input
        find(:xpath, "//input[@value='#{subjectName}']/parent::td/preceding-sibling::td/a[@title='Schedule']").click
        wait_for_javascript_to_finish

        commentBox = find(:xpath, "//div[@aria-hidden='false']//textarea[@class='comment_box']")
        commentBox.set("This is a fresh comment. Fresh comments smell nice.")
        find(:xpath, "//div[@aria-hidden='false']//a[contains(@class, 'add_comment_link')]").click
        wait_for_javascript_to_finish
        page.should have_content "This is a fresh comment. Fresh comments smell nice."
        
        click_link service.core
        #it is assumed here that the service sent in
        #is checked for fulfillment in the first visit available.
        page.should have_xpath "//div[@aria-hidden='false']//td[text()='#{service.name}']"
        check_subject_tracker_totals(service)
        
        completedBox = find(:xpath, "//div[@aria-hidden='false']//td[text()='#{service.name}']/following-sibling::td[contains(@class, 'check_box_cell')]/input[@type='checkbox']")
        completedBox.click
        wait_for_javascript_to_finish
        check_subject_tracker_totals(service)
        save_validation_check

        select 'Active', :from => 'subject_status'
        wait_for_javascript_to_finish
        save_validation_check
        
        select '--Choose a Status--', :from => 'subject_status'
        wait_for_javascript_to_finish
        save_validation_check

        # click_link "Back to Clinical Work Fulfillment"
        wait_for_javascript_to_finish
    end
    


    def subjectTracker(service)
        #expects instance of ServiceWithAddress as input
        #tests the subject tracker tab
        switchTabTo "Subject Tracker"
        if first(:xpath, "//tr[contains(@class, 'fields subject')]").nil? then #if no subjects available add one
            click_link "Add a subject"
        end

        #fill out first subject info
        first(:xpath, "//input[contains(@id,'subject_') and contains(@id,'_name')]").set("Bobby Cancerpatient")
        first(:xpath, "//input[contains(@id,'subject_') and contains(@id,'_mrn')]").set(143)
        first(:xpath, "//input[contains(@id,'subject_') and contains(@id,'_id')]").set(12)
        first(:xpath, "//input[contains(@id,'_dob')]").click
        wait_for_javascript_to_finish
        datePickerBox = find(:xpath, "//div[@id='ui-datepicker-div']")
        within datePickerBox do
            find(:xpath, "./div/div/select[@class='ui-datepicker-year']/option[text()='1945']").select_option
            click_link "22"
        end
        first(:xpath, "//select[contains(@id, '_gender')]/option[text()='Male']").select_option
        first(:xpath, "//select[contains(@id, '_ethnicity')]/option[text()='Caucasian']").select_option
        find(:xpath, "//div[@id='subjects']/form/p/input[@value='Save']").click
        wait_for_javascript_to_finish

        #test search for subject
        find(:xpath, "//input[@class='search-all-subjects ui-autocomplete-input']").set('Bobby')
        wait_for_javascript_to_finish
        page.should have_xpath "//li/a[text()='Bobby Cancerpatient']"
        find(:xpath, "//li/a[text()='Bobby Cancerpatient']").click
        wait_for_javascript_to_finish
        find(:xpath, "//div[@id='subjects']/form/p/input[@value='Save']").click
        wait_for_javascript_to_finish

        subjectVisitCalendarTest("Bobby Cancerpatient",service)

        #test add subject
        subjectsNum = all(:xpath, "//div/h3[text()='ARM 1']/following-sibling::table[contains(@id,'subjects_list')]/tbody/tr").length
        find(:xpath,"//a[@class='subject_tracker_add']",:visible => true).click
        wait_for_javascript_to_finish
        newSubjectsNum = all(:xpath, "//div/h3[text()='ARM 1']/following-sibling::table[contains(@id,'subjects_list')]/tbody/tr").length
        newSubjectsNum.should eq(subjectsNum+1)
        subjectsNum = newSubjectsNum

        #test remove subject
        first(:xpath, "//img [@src='/assets/cancel.png']").click
        page.driver.browser.switch_to.alert.accept
        wait_for_javascript_to_finish
        find(:xpath, "//div[@id='subjects']/form/p/input[@value='Save']").click
        wait_for_javascript_to_finish
        newSubjectsNum = all(:xpath, "//div/h3[text()='ARM 1']/following-sibling::table[contains(@id,'subjects_list')]/tbody/tr").length
        newSubjectsNum.should eq(subjectsNum-1)
    end

    def paymentsTab
        #tests the payments tab
        switchTabTo "Payments"
        paymentsNum = all(:xpath, "//table[@id='payments_list']/tbody/tr[not(@style)]").length
        if paymentsNum == 0 then 
            click_link "Add a payment"
            wait_for_javascript_to_finish
        end

        first(:xpath, "//td[@class='date_submitted']/input").click
        wait_for_javascript_to_finish
        dateSubmittedBox = find(:xpath, "//div[@id='ui-datepicker-div']")
        within dateSubmittedBox do
            find(:xpath, ".//td[contains(@class,'ui-datepicker-today')]/a").click
        end

        first(:xpath, "//td[@class='amount_invoiced']/input").set("1000.00")
        first(:xpath, "//td[@class='amount_received']/input").set("1000.00")

        first(:xpath, "//td[@class='date_received']/input").click
        wait_for_javascript_to_finish
        dateSubmittedBox = find(:xpath, "//div[@id='ui-datepicker-div']")
        within dateSubmittedBox do
            find(:xpath, ".//td[contains(@class,'ui-datepicker-today')]/a").click
        end

        first(:xpath, "//td[@class='payment_method']/select/option[text()='Check']").select_option
        first(:xpath, "//td[@class='details']/textarea").set("Details Here")

        find(:xpath, "//div[@id='payments']/form/p/input[@value='Save']").click
        wait_for_javascript_to_finish

        #test remove payment
        first(:xpath, "//table[@id='payments_list']/tbody/tr/td[@class='remove']/a").click
        page.driver.browser.switch_to.alert.accept
        wait_for_javascript_to_finish
        find(:xpath, "//div[@id='payments']/form/p/input[@value='Save']").click
        wait_for_javascript_to_finish
        newPaymentsNum = all(:xpath, "//table[@id='payments_list']/tbody/tr[not(@style)]").length
        if paymentsNum==1 then newPaymentsNum.should eq(paymentsNum)
        else newPaymentsNum.should eq(paymentsNum-1) end

        #test add payment
        paymentsNum = all(:xpath, "//table[@id='payments_list']/tbody/tr[not(@style)]").length
        click_link "Add a payment"
        wait_for_javascript_to_finish
        newPaymentsNum = all(:xpath, "//table[@id='payments_list']/tbody/tr[not(@style)]").length
        newPaymentsNum.should eq(paymentsNum+1)
        paymentsNum = newPaymentsNum

    end

    def checkTabsCWF
        #runs through each tab
        switchTabTo 'Subject Tracker'
        wait_for_javascript_to_finish

        switchTabTo 'Study Level Charges'
        wait_for_javascript_to_finish
        
        switchTabTo 'Payments'
        wait_for_javascript_to_finish
        
        switchTabTo 'Billing'
        wait_for_javascript_to_finish
        
        switchTabTo 'Study Schedule'
        wait_for_javascript_to_finish
    end

    def billingTab
        #tests the billing tab by adding a new cover letter then confirming that it exists on the SR
        switchTabTo "Billing"
        click_link "New cover letter"
        wait_for_javascript_to_finish
        find(:xpath, "//input[@type='submit']").click
        wait_for_javascript_to_finish
        page.should have_xpath "//table[@id='billings_list']/tbody/tr/td[@class='type' and text()='Cover Letter']"
    end

    def clinicalWorkFulfillment(study, service)
        #expects instance of CustomStudy as input
        #expects instance of ServiceWithAddress as input
        #Intended as full CWF happy test.
        goToCWF
        enterServiceRequest(study.short,service.name)
        testService(service)
        subjectTracker(service)
        paymentsTab
        billingTab
    end

end