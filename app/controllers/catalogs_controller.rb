class CatalogsController < ApplicationController
  def update_description
    @organization = Organization.find params[:id]
    @service_request = ServiceRequest.find session[:service_request_id]
  end
end
