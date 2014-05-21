class Portal::AdminController < Portal::BaseController
  def index
    # TODO: admin_service_requests_by_status returns *sub* service
    # requests, so this is a misnomer
    admin_orgs = @user.admin_organizations
    redirect_to root_path if admin_orgs.empty?
    
    @service_requests = @user.admin_service_requests_by_status(nil, admin_orgs)
    @study_tracker = false
  end
  
  def delete_toast_message
    @message = ToastMessage.find(params[:id])
    @message.destroy
    render :nothing => true
  end
end
