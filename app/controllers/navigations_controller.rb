class NavigationsController < ApplicationController
  before_filter :initialize_service_request
  before_filter :authorize_identity
  def index
    @institutions = Institution.all
    #@service_request = current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]
  end
end
