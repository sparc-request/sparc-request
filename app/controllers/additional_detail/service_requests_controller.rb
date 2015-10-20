class AdditionalDetail::ServiceRequestsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_identity! 
  
  # return json data for each line item additional detail, authorize using service_requester_id
  def show
    # version 1.0 only allows original service requester to view grid 
    # but we'll likely add more types of users to the list of authorized viewers
    @service_request = ServiceRequest.where(:id => params[:id], :service_requester_id => current_identity.id).first
    # as needed, get_or_create_line_item_additional_details creates new line item additional details
    if @service_request
      render :json => @service_request.get_or_create_line_item_additional_details.to_json(:root=> false, :methods => [:has_answered_all_required_questions?, :additional_detail_breadcrumb])
    else 
      render :json => "", :status => :unauthorized
    end
  end
  
end
