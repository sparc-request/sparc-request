class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :authenticate
  before_filter :set_service_request_id

  def authenticate
    @current_user = Identity.find 10332 #anc63
  end

  def set_service_request_id
    session[:service_request_id] ||= @service_request = @current_user.service_requests.find_or_create_by_id(:id => params[:service_request_id])
  end
end
