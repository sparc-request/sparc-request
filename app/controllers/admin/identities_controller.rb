class Admin::IdentitiesController < ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_identity! # returns 401 for failed JSON authentication
  before_filter :load_identity_and_authorize_super_users, :only => [:show, :update]
  
  def index
     # index.html displays user search box and results grid with "Add/Update User" functionality
  end

  def search
    results = []
    # Don't allow empty searches because that might stress LDAP and MySQL resources
    if params[:term] && params[:term].length > 2
      results = Directory.search_and_merge_ldap_and_database_results(params[:term])
    end
    # @TODO: limit result objects to only data that is needed/used
    render :json => results.to_json(:root => false) 
  end
  
  # respond to JSON requests to create new Identities
  # allow all users to add new users using LDAP data
  def create
   identity = Identity.new(first_name: params[:identity][:first_name], last_name: params[:identity][:last_name],
                               email: params[:identity][:email], ldap_uid: params[:identity][:ldap_uid],
                               password:   Devise.friendly_token[0,20], # generate a password that won't be used.
                               approved:   true)
    if identity.save
      render :json => identity.to_json(:root => false, :only => [:id, :first_name, :last_name, :email, :ldap_uid]) 
    else
      render json: identity.errors, status: :unprocessable_entity
    end 
  end
  
  # this provides the Edit modal with data,
  # only allow super users the ability to change the information originally provided by LDAP
  def show
    render :json => @identity.to_json(:root => false, :only => [:id, :first_name, :last_name, :email, :ldap_uid]) 
  end
    
  # respond to JSON requests to update Identities
  # only allow super users the ability to change the information originally provided by LDAP
  # only allow the updating of first name, last name, and email. 
  # LDAP UID needs to remain constant or else shibboleth authentication will create a new identity record for the person
  # 'approved' field is managed via an existing admin feature
  def update
    if @identity.update_attributes(first_name: params[:identity][:first_name], 
                                   last_name: params[:identity][:last_name],
                                   email: params[:identity][:email])
      render :json => @identity.to_json(:root => false, :only => [:id, :first_name, :last_name, :email, :ldap_uid]) 
    else
      render json: @identity.errors, status: :unprocessable_entity
    end 
  end
  
  private
  
  def load_identity_and_authorize_super_users
    # verify that the user is a super user 
    if current_identity.super_users.length > 0
      @identity = Identity.where(id: params[:id]).first()
      if !@identity 
        render :json => "", :status => :not_found 
      else
        return true
      end
    else
      respond_to do |format|
        format.html {render "unauthorized", :status => :unauthorized}
        format.json {render :json => "", :status => :unauthorized}
      end
    end
  end
end
