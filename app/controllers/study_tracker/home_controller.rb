class StudyTracker::HomeController < StudyTracker::BaseController
  def index
    @study_tracker = true
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer

    ##Passing in ctrc organization id, in order to only get ctrc ssrs back (method defaults to all ssrs)
    @org = Organization.tagged_with("ctrc").first
    @service_requests = @user.admin_service_requests_by_status(@org.id)

    ##Remove ssrs that are not flagged for study tracker/work fulfillment
    @service_requests.each_value do |status|
    	status.delete_if {|ssr| ssr.in_work_fulfillment == nil}
    end


    #redirect_to root_path if @user.admin_organizations.empty?
  end

  def billing_report_setup
    @admin_portal = true
    @render_billing_report = true
    # get cwf organizations
    @cwf_organizations = Organization.get_cwf_organizations
    @protocols = SubServiceRequest.where(:in_work_fulfillment => true).map{|x| x.service_request.protocol}.uniq
  end

  def billing_report
    @start = params[:study_tracker_billing_report_start_date]
    @end = params[:study_tracker_billing_report_end_date]
    @protocol_ids = params[:study_tracker_billing_report_protocol_ids] || ["All"]
    @protocol_ids.delete("All")

    if @protocol_ids.blank? or @protocol_ids == ["All"]
      @protocol_ids = SubServiceRequest.where(:in_work_fulfillment => true).map{|x| x.service_request.protocol.id}.uniq
    end
    
    @organization_ids = params[:organizations]

    @appointments = Appointment.joins(:visit_group => :arm)
                               .where("organization_id IN (#{@organization_ids.join(', ')}) AND completed_at BETWEEN '#{@start}' AND '#{@end}' AND arms.protocol_id IN (#{@protocol_ids.join(', ')})")
                               .order(:organization_id, "arms.protocol_id", :calendar_id, :completed_at)
  end
end
