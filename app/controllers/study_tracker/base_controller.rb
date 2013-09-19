class StudyTracker::BaseController < ActionController::Base
  layout 'portal/application'
  protect_from_forgery
  helper_method :current_user

  before_filter :authenticate_identity!
  before_filter :set_user
  before_filter :check_clinical_provider_rights

  def current_user
    current_identity
  end
  
  def set_user
    @user = current_identity
    session['uid'] = @user.nil? ? nil : @user.id
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end

  private
  def check_clinical_provider_rights
    unless @user.clinical_provider_rights?
      redirect_to root_path
    end
  end
end
