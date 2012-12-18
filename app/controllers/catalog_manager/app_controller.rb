# named AppController because Devise was having problems when it was named the same as the main ApplicationController
class CatalogManager::AppController < ActionController::Base
  layout 'catalog_manager/application'
  protect_from_forgery

  before_filter :authenticate_identity!
  before_filter :set_user

  def set_user
    @user = current_identity
    session['uid'] = @user.nil? ? nil : @user.id
  end
end
