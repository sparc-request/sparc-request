module CapybaraClinical
    include CapybaraAdminPortal

    def goToCWF
        #navigates to clinical work fulfillment home
        visit "/clinical_work_fulfillment"
        wait_for_javascript_to_finish
    end

    def testService(service)
        visitText = find(:xpath, "//select[@id='visit_position']/option[@value='']").text[4..-1]
        visitDay = visitText[6..-1]
        click_link "Add a Visit"
        currentBox = first(:xpath, "//div[contains(@class,'ui-dialog ') and contains(@style,'display: block;')]")
        within currentBox do
            fill_in 'visit_name', :with => visitText
            fill_in 'visit_day', :with => visitDay
            find(:xpath, ".//button/span[text()='Submit']").click
            wait_for_javascript_to_finish
        end

        select "Delete #{visitText} - #{visitText}", :from => 'delete_visit_position'
        click_link "Delete a Visit"
        wait_for_javascript_to_finish
    end

    def subjectTracker
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

        #test add subject
        subjectsNum = all(:xpath, "//div/h3[text()='ARM 1']/following-sibling::table[contains(@id,'subjects_list')]/tbody/tr").length
        find(:xpath, "//div/h3[text()='ARM 1']/following-sibling::p/a[text()='Add a subject']").click
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
        paymentsNum = all(:xpath, "//table[@id='payments_list']/tbody/tr[not(@style)]").length
        if paymentsNum == 0 then 
            click_link "Add a payment"
            wait_for_javascript_to_finish
        end

        first(:xpath, "//td[@class='date_submitted']/input").click
        wait_for_javascript_to_finish
        dateSubmittedBox = find(:xpath, "//div[@id='ui-datepicker-div']")
        within dateSubmittedBox do
            click_link Time.now.strftime("%-d")
        end

        first(:xpath, "//td[@class='amount_invoiced']/input").set("1000.00")
        first(:xpath, "//td[@class='amount_received']/input").set("1000.00")

        first(:xpath, "//td[@class='date_received']/input").click
        wait_for_javascript_to_finish
        dateSubmittedBox = find(:xpath, "//div[@id='ui-datepicker-div']")
        within dateSubmittedBox do
            click_link Time.now.strftime("%-d")
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

    def billingTab
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

        switchTabTo "Study Schedule"
        testService(service)

        switchTabTo "Subject Tracker"
        subjectTracker

        switchTabTo "Payments"
        paymentsTab

        switchTabTo "Billing"
        billingTab
    end

end