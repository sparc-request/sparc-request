class StudyTracker::BaseController < ActionController::Base
  layout 'portal/application'
  protect_from_forgery

  before_filter :authenticate_identity!
  before_filter :set_user
  before_filter :check_clinical_provider_rights

  def set_user
    @user = current_identity
    session['uid'] = @user.nil? ? nil : @user.id
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end

  private
  def check_clinical_provider_rights
    @org = Organization.tagged_with("ctrc").first
    if @user.clinical_providers.empty? && !@user.admin_organizations({:su_only => true}).include?(@org)
      redirect_to root_path
    end
  end
end
