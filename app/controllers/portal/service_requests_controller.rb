class Portal::ServiceRequestsController < Portal::BaseController
  respond_to :json, :js, :html

  def show
    session[:service_calendar_page] = params[:page] if params[:page]
    
    @service_request = ServiceRequest.find(params[:id])
    @service_list = @service_request.service_list
    @protocol = @service_request.protocol
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
    @tab = 'pricing'
    
    respond_to do |format|
      format.js
    end
  end

  def add_per_patient_per_visit_visit
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
    @service_request = ServiceRequest.find(params[:service_request_id]) # TODO: is this different from params[:id] ?
    if @service_request.add_visit(params[:visit_position])
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @service_request.relevant_service_providers_and_super_users.each do |identity|
        create_visit_change_toast(identity, @sub_service_request) unless identity == @user
      end
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@service_request.errors) } 
      end
    end
  end

  def remove_per_patient_per_visit_visit
    @service_request = ServiceRequest.find(params[:id])
    if @service_request.remove_visit(params[:visit_position])
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      @subsidy = @sub_service_request.subsidy
      percent = @subsidy.try(:percent_subsidy).try(:*, 100)
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      @service_request.relevant_service_providers_and_super_users.each do |identity|
        create_visit_change_toast(identity, @sub_service_request) unless identity == @user
      end
      render 'portal/service_requests/add_per_patient_per_visit_visit'
    else
      p @service_request.errors
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@service_request.errors) }
      end
    end
  end

  def update_from_fulfillment
    @service_request = ServiceRequest.find(params[:id])
    if @service_request.update_attributes(params[:service_request])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@service_request.errors) } 
      end
    end
  end

  def refresh_service_calendar
    @service_request = ServiceRequest.find(params[:id])
    session[:service_calendar_page] = params[:page] if params[:page]
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
    @tab = 'pricing'
  end

  ##### NOT ACTIONS #####
  def visit_count_total
    max_count = 0
    @service_request.sub_service_requests.each do |sub_service_request|
      sub_service_request.services.each do |service|
        if service.visits
          length = service.visits.length
          max_count = length if max_count < service.visits.length
        end
      end
    end
    max_count
  end

  def create_visit_change_toast identity, sub_service_request
    ToastMessage.create(
      :to => identity.id,
      :from => @user.id,
      :sending_class => 'SubServiceRequest',
      :sending_class_id => sub_service_request.id,
      :message => "The visit count on this service request has been changed"
    )
  end

end
