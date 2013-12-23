class Portal::AdminController < Portal::BaseController
  def index
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer
    admin_orgs = @user.admin_organizations
    @service_requests = @user.admin_service_requests_by_status(nil, admin_orgs)
    @study_tracker = false
    
    redirect_to root_path if admin_orgs.empty?
  end

  def billing_report_setup
    @admin_portal = true
    @render_billing_report = true
    # get cwf organizations
    @cwf_organizations = Organization.get_cwf_organizations
  end

  def billing_report
    @start = params[:admin_billing_report_start_date]
    @end = params[:admin_billing_report_end_date]
    @organization_ids = params[:organizations]

    @appointments = Appointment.where("organization_id IN (#{@organization_ids.join(', ')}) AND completed_at BETWEEN '#{@start}' AND '#{@end}'")
  end

  def delete_toast_message
    @message = ToastMessage.find(params[:id])
    @message.destroy
    render :nothing => true
  end
end
