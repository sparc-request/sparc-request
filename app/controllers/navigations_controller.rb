class NavigationsController < ApplicationController
  def index
    @institutions = Institution.all
    @service_request = @current_user.service_requests.find session[:service_request_id]
  end
end
