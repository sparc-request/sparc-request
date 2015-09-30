class AdditionalDetail::ServiceRequestsController < ApplicationController
  protect_from_forgery
  #before_filter :authenticate_identity! 
  
  # return json data of each line item additional detail, authorize using service_requester_id
  def show
    #puts params.inspect
    #puts session.inspect # why doesn't this include :identity_id ??
    @service_request = ServiceRequest.where(:id => params[:id]).first # need to add , :service_requester_id => session[:identity_id]
    render :json => @service_request.get_additional_details
  end
  
  def line_item_additional_detail
    @service_request = ServiceRequest.where(:id => params[:id]).first
    render :json => @service_request.get_line_item_additional_details
  end
  
  
end
