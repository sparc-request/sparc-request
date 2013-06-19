class StudyTracker::SubServiceRequestsController < StudyTracker::BaseController
  respond_to :js, :html

  def show
    @sub_service_request = SubServiceRequest.find(params[:id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end

    session[:sub_service_request_id] = @sub_service_request.id
    session[:service_request_id] = @sub_service_request.service_request_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]

    @service_request = @sub_service_request.service_request
    @protocol = @sub_service_request.try(:service_request).try(:protocol)
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
    @selected_arm = @service_request.arms.first

    @study_tracker = true
    
  end

  def service_calendar
    @sub_service_request = SubServiceRequest.find(params[:id])
    @service_request = @sub_service_request.service_request

    # #use session so we know what page to show when tabs are switched
    # session[:service_calendar_pages] = params[:pages] if params[:pages]

    # # TODO: why is @page not set here?  if it's not supposed to be set
    # # then there should be a comment as to why it's set in #review but
    # # not here
  end

  # def update_from_fulfillment
  #   @sub_service_request = SubServiceRequest.find(params[:id])
  #   if @sub_service_request.update_attributes(params[:sub_service_request])
  #     @sub_service_request.generate_approvals(@user)
  #     @service_request = @sub_service_request.service_request
  #     @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
  #     render 'portal/sub_service_requests/update_past_status'
  #   else
  #     respond_to do |format|
  #       format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
  #     end
  #   end
  # end

  # def update_from_project_study_information
  #   @protocol = Protocol.find(params[:protocol_id])
  #   @sub_service_request = SubServiceRequest.find params[:id]

  #   attrs = params[@protocol.type.downcase.to_sym]
    
  #   if @protocol.update_attributes attrs
  #     redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
  #   else
  #     @user_toasts = @user.received_toast_messages.select {|x| x.sending_object.class == SubServiceRequest}
  #     @service_request = @sub_service_request.service_request
  #     @protocol.populate_for_edit if @protocol.type == "Study"
  #     @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.is_one_time_fee?}
  #     @subsidy = @sub_service_request.subsidy
  #     @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
  #     @service_list = @service_request.service_list
  #     @related_service_requests = @protocol.all_child_sub_service_requests
  #     @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
  #     @selected_arm = @service_request.arms.first
  #     render :action => 'show'
  #   end
  # end

end