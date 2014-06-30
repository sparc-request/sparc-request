module CapybaraUserPortal
    include CapybaraAdminPortal

    def goToUserPortal
        #navigates to user portal
        visit "/portal"
        wait_for_javascript_to_finish
    end

    def createNewRequestTest
        #clicks on the Create New Request button and 
        #checks that it takes the browser to sparc proper
        find(:xpath, "//a/img[@class='portal_create_new_request']").click
        wait_for_javascript_to_finish
        page.should have_xpath "//div[@id='institution_accordion']"
        goToUserPortal
    end

    def editOriginalTest(request)
        #expects instance of ServiceRequestForComparison as input 
        find(:xpath, "//a[@class='edit_service_request' and text()='Edit Original']").click
        wait_for_javascript_to_finish
        assert_selector(:xpath, "//div[@class='line-items']/div[@class]", :count => request.services.length)
        goToUserPortal
        findStudy(request.study.short)
    end

    def findStudy(studyName)
        #expects string of the study in question's name
        #searches for the study, finds it, and clicks on it to expand its accordion
        searchBoxTest(true, studyName)
        accordion = find(:xpath, "//div[@id='protocol-accordion' and @role='tablist']")
        within accordion do
            studyTitle = find(:xpath, "./h3[@role='tab']/a/div[contains(text(),'#{studyName}')]/parent::a/parent::h3")
            if studyTitle['aria-selected']=="false" then studyTitle.click end
            wait_for_javascript_to_finish
        end
    end

    def accordionInfoBox
        #returns currently expanded study information div that
        #  displays the study information, users, and SRs.
        find(:xpath, "//div[@aria-expanded='true']")
    end

    def createNotification(studyName)
        #expects string of the study in question's name
        #adds Jason Leonard as an authorized user, 
        #logs in as Jason and goes to his user portal
        #sends a notification to Julia as Jason
        #logs in as Julia again and returns to study in Julia's User Portal
        authorizedUsersTest("leonarjp", "Jason Leonard")
        click_link "logout"
        goToSparcProper("jpl6@musc.edu","p4ssword")
        goToUserPortal
        findStudy studyName
        within accordionInfoBox do
            first(:xpath, ".//a[contains(@class,'new-portal-notification-button')]").click
            wait_for_javascript_to_finish
        end
        first(".new_notification").click
        wait_for_javascript_to_finish
        currentBox = find(:xpath, "//div[contains(@class,'ui-dialog ') and contains(@style,'display: block;')]")
        within currentBox do 
            find("#message_body").set("This text sent to Julia.")
            first(:xpath, ".//button/span[text()='Send']").click
            wait_for_javascript_to_finish
        end
        wait_for_javascript_to_finish
        click_link "logout"
        goToSparcProper
        goToUserPortal
        findStudy studyName
    end

    def notificationsTest(studyName)
        #expects string of the study in question's name
        #creates a notification, goes to notifications center
        #replies to notification, goes to UP, attempts to send notification to self
        #checks for error response about sending notification to self.
        createNotification studyName
        visit "/portal/notifications"
        wait_for_javascript_to_finish
        if not have_css("tr.notification_row.unread") then
            goToUserPortal
            return
        end
        page.should have_content "This text sent to Julia"
        find("td.subject_column").click
        wait_for_javascript_to_finish
        find("div.shown-message-body").should be_visible
        page.fill_in 'message[body]', :with => "Test Reply"
        click_button("Submit")
        wait_for_javascript_to_finish
        find("td.body_column").should have_text("Test Reply")
        goToUserPortal
        within accordionInfoBox do
            sleep 2
            first(:xpath, ".//a[@class='new-portal-notification-button']").click
            wait_for_javascript_to_finish
        end
        first(".new_notification").click
        wait_for_javascript_to_finish
        page.should have_text("You can not send a message to yourself.")
        goToUserPortal
    end

    def saveStudy
        find(:xpath, "//input[@value='Save']").click
        # click_button "Save Study"
        wait_for_javascript_to_finish
    end        

    def goToEditStudy(studyID)
        # visit edit_portal_protocol_path service_request.protocol.id
        #goes to page that enables user in UP to edit study information
        visit "/portal/protocols/#{studyID}/edit"
        wait_for_javascript_to_finish
    end

    def editStudyInformation
        #tests the edit study information page
        wait_for_javascript_to_finish
        numerical_day = Time.now.strftime("%-d") # Today's Day
        studyID = accordionInfoBox.find(:xpath, "./div[@class='protocol-information-body ui-corner-bottom']/div/ul/li[contains(text(),'Study ID:')]").text.strip[9..-1].strip
       
        within accordionInfoBox do
            editInfoButton = find(:xpath, "./div/div/div[@class='protocol-information-button ui-corner-all']")
            editInfoButton.click
        end
        # it "should raise an error message if study's status is pending and no potential funding source is selected" do
        select("Pending Funding", :from => "Proposal Funding Status")
        saveStudy
        page.should have_content("1 error prohibited this study from being saved")

        # it "should raise an error message if study's status is funded but no funding source is selected" do
        select("Funded", :from => "Proposal Funding Status")
        select("Select a Funding Source", :from => "study_funding_source")
        saveStudy
        page.should have_content("1 error prohibited this study from being saved")

        # it "should redirect to the main portal page" do
        select("Federal", :from => "study_funding_source")
        saveStudy
        page.should have_content("Welcome")

        # it "should save the new short title" do
        goToEditStudy(studyID)
        wait_for_javascript_to_finish
        fill_in "study_short_title", :with => "Bob"
        saveStudy
        goToEditStudy(studyID)
        find("#study_short_title").should have_value("Bob")

        # it "should save the new protocol title" do
        fill_in "study_title", :with => "Slappy"
        saveStudy
        goToEditStudy(studyID)
        find("#study_title").should have_value("Slappy")

        # it "should change to pending funding" do
        select("Pending Funding", :from => "Proposal Funding Status")
        find("#study_funding_status").should have_value("pending_funding")

        # it "should change to funded" do
        select("Funded", :from => "Proposal Funding Status")
        find("#study_funding_status").should have_value("funded")
        select("Federal", :from => "study_funding_source")

        # it "should save the new udak/project number" do
        fill_in "study_udak_project_number", :with => "12345"
        saveStudy
        goToEditStudy(studyID)
        find("#study_udak_project_number").should have_value("12345")

        # it "should save the new sponsor name" do
        fill_in "study_sponsor_name", :with => "Kurt Zanzibar"
        saveStudy
        goToEditStudy(studyID)
        find("#study_sponsor_name").should have_value("Kurt Zanzibar")

        # it "should change and save the date" do
        select("Funded", :from => "Proposal Funding Status")
        find("#funding_start_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on todays date
        wait_for_javascript_to_finish
        find("#funding_start_date").should have_value(Date.today.strftime('%-m/%d/%Y'))

        # it "should change the indirect cost rate when a source is selected" do
        select("Funded", :from => "Proposal Funding Status")
        select("Foundation/Organization", :from => "study_funding_source")
        find("#study_indirect_cost_rate").should have_value("25")
        select("Federal", :from => "study_funding_source")
        find("#study_indirect_cost_rate").should have_value("49.5")

        # it "should save the new funding opportunity number" do
        select("Pending Funding", :from => "Proposal Funding Status")
        select("Federal", :from => "study_potential_funding_source")
        fill_in "study_funding_rfa", :with => "12345"
        saveStudy
        goToEditStudy(studyID)
        find("#study_funding_rfa").should have_value("12345")

        # it "should change and save the date" do
        select("Pending Funding", :from => "Proposal Funding Status")
        select("Federal", :from => "study_potential_funding_source")
        find("#potential_funding_start_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#potential_funding_start_date").should have_value((Date.today).strftime('%-m/%d/%Y'))

        # it "should change the indirect cost rate when a source is selected" do
        select("Pending Funding", :from => "Proposal Funding Status")
        select("Federal", :from => "study_potential_funding_source")
        select("Foundation/Organization", :from => "study_potential_funding_source")
        find("#study_indirect_cost_rate").should have_value("25")

        # it "should change the study phase" do
        select("Pending Funding", :from => "Proposal Funding Status")
        select("Federal", :from => "study_potential_funding_source")
        select("IV", :from => "Study Phase")
        find("#study_study_phase").should have_value("iv")

        # it "should cause all the human subjects fields to become visible" do
        check("study_research_types_info_attributes_human_subjects")
        find("#study_human_subjects_info_attributes_hr_number").should be_visible

        # it "should change state when clicked" do
        check("study_research_types_info_attributes_human_subjects")
        check("study_research_types_info_attributes_human_subjects")
        find("#study_research_types_info_attributes_human_subjects").should be_checked

        # it "should save the new hr and pro number" do
        field_array = ["hr_number", "pro_number"]
        field_num = 0
        2.times do 
            fill_in "study_human_subjects_info_attributes_#{field_array[field_num]}", :with => "12345"
            field_num += 1
        end
        saveStudy
        goToEditStudy(studyID)
        find("#study_human_subjects_info_attributes_hr_number").should have_value("12345")
        find("#study_human_subjects_info_attributes_pro_number").should have_value("12345")

        # it "should save the new irb" do
        fill_in "study_human_subjects_info_attributes_irb_of_record", :with => "crazy town"
        saveStudy
        goToEditStudy(studyID)
        find("#study_human_subjects_info_attributes_irb_of_record").should have_value("crazy town")

        # it "should change the submission type" do
        select("Exempt", :from => "Submission Type")
        find("#study_human_subjects_info_attributes_submission_type").should have_value("exempt")

        # it "should change and save the date" do
        find("#irb_approval_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_approval_date").should have_value(Date.today.strftime('%-m/%d/%Y'))

        # it "should change and save the date" do
        find("#irb_expiration_date").click
        page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") }
        find("#irb_expiration_date").should have_value(Date.today.strftime('%-m/%d/%Y'))

        # it "should change their state when clicked" do
        box_array = ["vertebrate_animals", "investigational_products", "ip_patents"]
        box_num = 0
        3.times do
            check("study_research_types_info_attributes_#{box_array[box_num]}")
            box_num += 1
        end
        find("#study_research_types_info_attributes_vertebrate_animals").should be_checked
        find("#study_research_types_info_attributes_investigational_products").should be_checked
        find("#study_research_types_info_attributes_ip_patents").should be_checked

        # it "should change their state when clicked" do
        box_num = 0
        3.times do
            check("study_study_types_attributes_#{box_num}__destroy")
            box_num += 1
        end
        find("#study_study_types_attributes_0__destroy").should be_checked
        find("#study_study_types_attributes_1__destroy").should be_checked
        find("#study_study_types_attributes_2__destroy").should be_checked

        # it "should change their state when clicked" do
        box_num = 0
        7.times do
            #check each checkbox
            check("study_impact_areas_attributes_#{box_num}__destroy")
            box_num += 1
        end
        box_num = 0
        7.times do
            #each checkbox should be checked
            find("#study_impact_areas_attributes_#{box_num}__destroy").should be_checked
            box_num += 1
        end

        # it "should open up text field when 'other' is checked" do
        check("study_impact_areas_attributes_6__destroy")
        find("#study_impact_areas_other").should be_visible 

        # it "should save the value after text is entered" do
        check("study_impact_areas_attributes_6__destroy")
        fill_in "study_impact_areas_other", :with => "El Guapo's Area"
        wait_for_javascript_to_finish
        saveStudy
        goToEditStudy(studyID)
        find("#study_impact_areas_other").should have_value("El Guapo's Area")

        # it "should change their state when clicked" do
        box_num = 0
        7.times do
            #check each checkbox
            check("study_affiliations_attributes_#{box_num}__destroy")
            box_num += 1
        end
        box_num = 0
        7.times do
            #each checkbox should be checked
            find("#study_affiliations_attributes_#{box_num}__destroy").should be_checked
            box_num += 1
        end        
        saveStudy
    end

    def authorizedUsersTest(usersID, usersName)
        #expects the strings of the user's ID and Name in order to search for them and add them.
        #adds an authorized user to the project and checks that the user has been added.
        usersFirstName = usersName.split[0]
        if not accordionInfoBox.first(:xpath, "./div[@class='protocol-information-table']/table/tbody/tr/td[contains(text(), '#{usersFirstName}')]").nil? then
            accordionInfoBox.first(:xpath, "./div[@class='protocol-information-table']/table/tbody/tr/td[contains(text(), '#{usersFirstName}')]/following-sibling::td/a[@class='delete-associated-user-button']").click
            page.driver.browser.switch_to.alert.accept
            wait_for_javascript_to_finish
        end

        accordionInfoBox.find(:xpath, "./div[@class='associated-user-button']").click
        wait_for_javascript_to_finish

        addBox = find(:xpath, "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;')]")
        addBox.find(:xpath, ".//input[@id='user_search']").set(usersID)
        wait_for_javascript_to_finish
        begin
            #if there is more than one response with the same name, this will fail.
            find(:xpath, "//ul[contains(@class,'ui-autocomplete')]/li/a[contains(text(),'#{usersName}')]").click
        rescue
            #choose the first response with the user's name if the above fails.
            first(:xpath, "//ul[contains(@class,'ui-autocomplete')]/li/a[contains(text(),'#{usersName}')]").click
        end
        wait_for_javascript_to_finish
        select "Other", :from => 'project_role_role'
        find(:xpath, "//input[@id='project_role_project_rights_approve']").click

        addBox.find(:xpath, ".//button/span[text()='Submit']").click
        wait_for_javascript_to_finish

        page.should have_xpath "//div[@aria-expanded='true']/div[@class='protocol-information-table']/table/tbody/tr/td[contains(text(), '#{usersFirstName}')]"

    end

    def userPortal(request)
        #expects instance of ServiceRequestForComparison as input 
        #Intended as full UP happy test.
        goToUserPortal
        createNewRequestTest
        findStudy(request.study.short)
        editOriginalTest(request)
        editStudyInformation
        authorizedUsersTest("bjk7", "Brian Kelsey")
        notificationsTest request.study.short
    end

end