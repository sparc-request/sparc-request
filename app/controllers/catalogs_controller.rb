class CatalogsController < ApplicationController
  before_filter :initialize_service_request
  before_filter :authorize_identity
  def update_description
    @organization = Organization.find params[:id]
    @service_request = ServiceRequest.find session[:service_request_id]
  end
end
