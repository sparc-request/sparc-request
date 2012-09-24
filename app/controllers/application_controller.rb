class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :authenticate

  def authenticate
    @current_user = Identity.find 10332 #anc63
  end
end
