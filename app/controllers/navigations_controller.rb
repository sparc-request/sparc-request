class NavigationsController < ApplicationController
  def index
    @institutions = Institution.all
    @service_request = @current_user.service_requests.where(:id => params[:service_request_id]).first_or_initialize
  end

  def update_description
    @organization = Organization.find(params[:id])
  end
end
