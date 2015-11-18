class Admin::IdentitiesController < ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_identity! # returns 401 for failed JSON authentication
  before_filter :authorize_super_users_service_providers, :only => [:show, :update]
  
  def index
     # index.html displays user search box with "Add/Update User" functionality
  end

  def search
    results = []
    # Don't allow empty searches because that might stress LDAP and MySQL resources
    if params[:term] && params[:term].length > 2 # this length check needs to be in sync with the AngularJS length check
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
      render :json => identity.to_json(:root => false) 
    else
      render json: identity.errors, status: :unprocessable_entity
    end 
  end
  
  # this provides the Edit modal with data,
  # only allow service providers and super users the ability to change the information originally provided by LDAP
  def show
  #  render :json => @service.additional_details.find(params[:id]).to_json(:root => false, :include => {:line_item_additional_details  => {:methods => [:sub_service_request_status, :srid, :pi_name, :protocol_short_title, :service_requester_name, :sub_service_request_id, :has_answered_all_required_questions?]}})
  end
    
  # respond to JSON requests to update Identities
  # only allow service providers and super users the ability to change the information originally provided by LDAP
  def update
  #  if @line_item_additional_detail.update_attributes(params[:line_item_additional_detail])
  #    head :no_content
  #  else
  #    render json: @line_item_additional_detail.errors, status: :unprocessable_entity
  #  end 
  end
  
  private
  
  def authorize_super_users_service_providers
    # verify that user is either a service provider or super user for this service but not catalog managers 
    if current_identity.super_users.length > 0 || current_identity.service_providers.length > 0
      return true
    else
      respond_to do |format|
        format.html {render "unauthorized", :status => :unauthorized}
        format.json {render :json => "", :status => :unauthorized}
      end
    end
  end
end
