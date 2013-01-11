class Portal::BaseController < ActionController::Base
  layout 'portal/application'
  protect_from_forgery

  before_filter :authenticate_identity!
  before_filter :set_user

  def set_user
    @user = current_identity
    session['uid'] = @user.nil? ? nil : @user.id
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end
end
