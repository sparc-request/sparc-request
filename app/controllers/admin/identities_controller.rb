class Admin::IdentitiesController < ApplicationController
  
  protect_from_forgery

  before_filter :authenticate_identity! # returns 401 for failed JSON authentication
  before_filter :authorize_super_users_service_providers
  
  def index
     # index.html displays user search box with "Add/Update User" functionality
  end

  def search
    render json: [].to_json
#    term = params[:term].strip
#    results = Identity.search(term).map do |i| 
#      {
#       :label => i.display_name, :value => i.id, :email => i.email, :institution => i.institution, :phone => i.phone, :era_commons_name => i.era_commons_name,
#       :college => i.college, :department => i.department, :credentials => i.credentials, :credentials_other => i.credentials_other
#      }
#    end
#    results = [{:label => 'No Results'}] if results.empty?
#    render :json => results.to_json
  end
  
  # respond to JSON requests to create new Identities
  def create
  #  if @line_item_additional_detail.update_attributes(params[:line_item_additional_detail])
  #    head :no_content
  #  else
  #    render json: @line_item_additional_detail.errors, status: :unprocessable_entity
  #  end 
  end
  
  def show
  #  render :json => @service.additional_details.find(params[:id]).to_json(:root => false, :include => {:line_item_additional_details  => {:methods => [:sub_service_request_status, :srid, :pi_name, :protocol_short_title, :service_requester_name, :sub_service_request_id, :has_answered_all_required_questions?]}})
  end
    
  # respond to JSON requests to update Identities
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
