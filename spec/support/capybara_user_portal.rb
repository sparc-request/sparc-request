module CapybaraUserPortal
    include CapybaraAdminPortal

    def goToUserPortal
        #navigates to user portal
        visit "/portal"
        wait_for_javascript_to_finish
    end

    def userPortal(request)
        goToUserPortal
        
    end

end