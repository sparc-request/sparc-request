module CapybaraAdminPortal

    def goToAdminPortal
        visit "/portal/admin"
        wait_for_javascript_to_finish
    end

    def enterServiceRequest(studyShortName, serviceName)
        find(:xpath, "//table[@id='admin-tablesorter']/tbody/tr/td/ul/span[text()='#{serviceName}']/ancestor::tr/td[text()='#{studyShortName}']").click
    end

    def adminPortal(request)
        goToAdminPortal
        enterServiceRequest(request.study.short,request.services[0].name)
        sleep 2400  
    end

end