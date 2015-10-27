class AdditionalDetail::ServicesController < ApplicationController
  protect_from_forgery
  
  layout 'additional_detail/application'
    
  before_filter :authenticate_identity!
  before_filter :load_service, :only => [:show]
  before_filter :authorize_admin_user, :only => [:show]
  
  def index
    # set up a page to select from available services??
  end
  
  def show
    respond_to do |format|
      # redirect HTML requests to the additional details admin page
      format.html {redirect_to additional_detail_service_additional_details_path(@service)}
      # JSON used by additional details admin page
      format.json {render :json => @service.to_json(:root => false, :include => :current_additional_detail) }
    end
  end
  
  private
  
  def load_service
    @service = Service.where(id: params[:id]).first()
    if !@service
      respond_to do |format|
        format.html {render "additional_detail/services/not_found", :status => :not_found}
        format.json {render :json => "", :status => :not_found }
      end
    end
  end
  
  def authorize_admin_user
    # verify that user is either a service provider, catalog manager, or super user for this service
    if current_identity.admin_organizations().include?(@service.organization) || current_identity.can_edit_entity?(@service.organization, true)
      return true
    else
      @service = nil
      render :json => "", :status => :unauthorized
    end
  end

end
