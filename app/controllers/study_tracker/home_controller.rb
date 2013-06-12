class StudyTracker::HomeController < StudyTracker::BaseController
  def index
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer

    ##Passing in ctrc organization id, in order to only get ctrc ssrs back (method defaults to all ssrs)
    
    @service_requests = @user.admin_service_requests_by_status(@org.id)

    ##Remove ssrs that are not flagged for study tracker/work fulfillment
    @service_requests.each_value do |status|
    	status.delete_if {|ssr| ssr.in_work_fulfillment == nil}
    end


    #redirect_to root_path if @user.admin_organizations.empty?
  end
end
