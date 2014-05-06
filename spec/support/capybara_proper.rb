module CapybaraProper


    def submitServiceRequest()
        #**Submit a service request**#
        page.should_not have_xpath("//div[@id='submit_error' and @style!='display: none']")
        find('.submit-request-button').click #Submit with no services
        wait_for_javascript_to_finish
        page.should have_xpath("//div[@id='submit_error' and @style!='display: none']") #should have error dialog
        click_button('Ok') 

        wait_for_javascript_to_finish
        begin
            click_link("South Carolina Clinical and Translational Institute (SCTR)")
        rescue
            click_link("Medical University of South Carolina")
            wait_for_javascript_to_finish
            click_link("South Carolina Clinical and Translational Institute (SCTR)")
        end

        find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")

        click_link("Office of Biomedical Informatics")
        wait_for_javascript_to_finish
        click_button("Add")
        wait_for_javascript_to_finish

        click_link("Clinical and Translational Research Center (CTRC)")
        wait_for_javascript_to_finish
        click_button("Add")
        wait_for_javascript_to_finish

        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should display 2 services
        find(:xpath,"//a[@id='line_item-1' and @class='remove-button']").click  #remove first service
        wait_for_javascript_to_finish
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('1') #should display 1 service
        find(:xpath,"//a[@id='line_item-2' and @class='remove-button']").click #remove last service
        wait_for_javascript_to_finish
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('0') #should display no services

        click_link("Office of Biomedical Informatics")
        wait_for_javascript_to_finish
        click_button("Add") #re-add first service
        wait_for_javascript_to_finish

        fill_in 'service_query', :with => "Breast Milk"
        wait_for_javascript_to_finish
        page.should have_xpath("//li[@class='search_result']/span[@class='service-name' and text()='Breast Milk Collection']")
        first(:xpath, "//li[@class='search_result']/span[@class='service-name' and text()='Breast Milk Collection']/following-sibling::button[@class='add_service']").click
        wait_for_javascript_to_finish

        click_link("Clinical and Translational Research Center (CTRC)")
        # wait_for_javascript_to_finish
        # click_button("Add") #re-add last service
        # wait_for_javascript_to_finish

        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should display 2 services
        find(:xpath, "//span[@class='title']/button[@class='add_service' and @sr_id='1']").click #add last service a second time
        wait_for_javascript_to_finish
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should only display 2 services

        find('.submit-request-button').click
        wait_for_javascript_to_finish
        #**END Submit a service request END**#
        ServiceRequest.find(1).line_items.count.should eq(2) #Should have 2 Services
    end


    def createNewStudy()
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


    def selectStudyUsers()
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


    def removeServices()
        #**Select Study**#
            #Remove services
        find(:xpath,"//a[@id='line_item-3' and @class='remove-button']").click
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('1') #should display 1 service
        find(:xpath,"//a[@id='line_item-4' and @class='remove-button']").click
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('0') #should display 0 services
        click_link("Save & Continue")
        wait_for_javascript_to_finish
        #**END Select Study END**#        
    end


    def enterProtocolDates()
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


    def readdServices()
            #Should have no services and instruct to add some
        page.should have_xpath("//div[@class='instructions' and contains(text(),'continue unless you have services in your cart.')]")
            #re-adding services
        click_link("Back to Catalog")
        click_link("South Carolina Clinical and Translational Institute (SCTR)")
        find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")
        click_link("Office of Biomedical Informatics")
        wait_for_javascript_to_finish
        click_button("Add")
        wait_for_javascript_to_finish
        click_link("Clinical and Translational Research Center (CTRC)")
        wait_for_javascript_to_finish
        click_button("Add")
        wait_for_javascript_to_finish
        find(:xpath, "//input[@id='line_item_count']")['value'].should eq('2') #should only display 2 services
        find('.submit-request-button').click
        wait_for_javascript_to_finish
        click_link("Save & Continue")
        wait_for_javascript_to_finish        
    end


    def chooseArmPreferences(subjects, visits)
            #edit Arm 1
        fill_in "study_arms_attributes_0_subject_count", :with => subjects # of subjects
        fill_in "study_arms_attributes_0_visit_count", :with => visits # of visits
        wait_for_javascript_to_finish
            #add Arm 2
        click_link("Add Arm")
        wait_for_javascript_to_finish
        find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell']/input[@type!='hidden']").set("ARM 2") #name arm2
        find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell skinny_fields']/input[contains(@name,'subject_count')]").set(subjects) # 5 subjects
        find(:xpath, "//div[@class='add-arm']/div/div[@class='arm-cell skinny_fields']/input[contains(@name,'visit_count')]").set(visits) # 5 visits
        wait_for_javascript_to_finish

        click_link("Save & Continue")
        #wait_for_javascript_to_finish
        #**END Enter Protocol Dates END**#       
    end


    def completeVisitCalender()
        #**Completing Visit Calender**#
            #save unit prices
        arm1UnitPrice = find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
        arm2UnitPrice = find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
        otfUnitPrice = find(:xpath, "//td[contains(text(),'CDW')]/ancestor::table//td[@class='your_cost']").text[1..-1].to_f
            #total per study should be $0.00
        find(:xpath, "//td[@class='pp_line_item_study_total total_1_per_study']").text[1..-1].to_f.should eq(0.0) #arm1
        find(:xpath, "//td[@class='pp_line_item_study_total total_3_per_study']").text[1..-1].to_f.should eq(0.0) #arm2
            #total per patient should be $0.00
        find(:xpath, "//td[@class='pp_line_item_total total_1']").text[1..-1].to_f.should eq(0.0) #arm1
        find(:xpath, "//td[@class='pp_line_item_total total_3']").text[1..-1].to_f.should eq(0.0) #arm2
            #set days in increasing order on ARM 1
        find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_1']").set("1")
        find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_2']").set("2")
        find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_3']").set("3")
        find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_4']").set("4")
        find(:xpath, "//th[contains(text(),'ARM 1')]/ancestor::table//input[@id='day' and @class='visit_day position_5']").set("5")

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
        find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_1']").set("1")
        find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_2']").set("2")
        find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_3']").set("3")
        find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_4']").set("4")
        find(:xpath, "//th[contains(text(),'ARM 2')]/ancestor::table//input[@id='day' and @class='visit_day position_5']").set("5")
          
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
