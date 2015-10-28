class AdditionalDetail::ServiceRequestsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_identity! 
  before_filter :load_and_authorize_service_request
  
  # return json data for each line item additional detail
  # if it's the first visit to the Notes & Documents page for this service request,
  #   this call will create the required rows of line item additional details
  def show
    respond_to do |format|
      format.html # show.html.haml, used by portal/dashboard users
      #format.json {render :json => @service_request.get_or_create_line_item_additional_details.to_json(:root=> false, :methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb])}
      format.json {render :json => @service_request.to_json(:root=> false, :only => [], :methods => [:protocol_short_title], :include => { :get_or_create_line_item_additional_details => {:methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb] }})}   
    end
  end
  
  private
  # authorize first by service requester id then by project team role (approve or request rights).
  # super users, catalog managers, and service providers do NOT need access 
  #   because they have access to the Additional Detail admin tool and can view additional details via /portal/admin/
  def load_and_authorize_service_request
    @service_request = ServiceRequest.where(id: params[:id]).first()
    if !@service_request 
      respond_to do |format|
        format.html {render "not_found", :status => :not_found}
        format.json {render :json => "", :status => :not_found }
      end
    elsif  @service_request.service_requester_id != current_identity.id && !current_identity.has_correct_project_role?(@service_request)
      @service_request = nil
      respond_to do |format|
        format.html {render "additional_detail/shared/unauthorized", :status => :unauthorized}
        format.json {render :json => "", :status => :unauthorized}
      end
    end
  end
  
end
