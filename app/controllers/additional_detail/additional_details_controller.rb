class AdditionalDetail::AdditionalDetailsController < ApplicationController
  protect_from_forgery

  before_filter :authenticate_identity! # returns 401 for failed JSON authentication
  before_filter :load_service
  before_filter :authorize_admin_user, :only => [:index]
  before_filter :authorize_super_users_catalog_managers, :except => [:index]
  
  # service providers need access to the index page so that they can click through to see responses
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => @service.additional_details.to_json(:root => false, :include => :line_item_additional_details)}
    end
  end

  # show responses with high level detail to be used for admin editing
  def show
    render :json => @service.additional_details.find(params[:id]).to_json(:root => false, :include => {:line_item_additional_details  => {:methods => [:sub_service_request_status, :pi_name, :protocol_short_title, :service_requester_name, :sub_service_request_id, :has_answered_all_required_questions?]}})
  end

  # show responses with low level details to be used for exporting
  # def export_grid
  # end
  
  def edit
    @additional_detail = @service.additional_details.find(params[:id])
    render :new
  end

  def new
    @additional_detail = @service.additional_details.new
  end

  def create
    @additional_detail = @service.additional_details.new(params[:additional_detail])
    if @additional_detail.save
      redirect_to additional_detail_service_additional_details_path(@service) #, flash: "Additional Detail form was successfully created."
    else
      render :new
    end
  end
  
  def duplicate
    @additional_detail = @service.additional_details.find(params[:id]).dup
    # force the admin user to choose a new effective date, should help prevent validation that checks for duplicate effective dates
    @additional_detail.effective_date = nil
    render :new
  end

  def update
    @additional_detail = @service.additional_details.find(params[:id])
    if @additional_detail.update_attributes(params[:additional_detail])
      redirect_to additional_detail_service_additional_details_path(@service)
    else
      render :new
    end
  end
  
  # from a JSON PUT, toggle only the :enabled attribute 
  def update_enabled
    @additional_detail = @service.additional_details.find(params[:id])
    # bypass validation to toggle :enabled
    if @additional_detail.update_attribute(:enabled, params[:additional_detail][:enabled])
      head :no_content
    else
      render json: @additional_detail.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @additional_detail = @service.additional_details.find(params[:id])
    if @additional_detail.destroy
      head :no_content
    else
      render json: @additional_detail.errors, status: :unprocessable_entity
    end
  end

  private

  def load_service
    @service = Service.where(id: params[:service_id]).first()
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
      render "additional_detail/shared/unauthorized", :status => :unauthorized
    end
  end
  
  def authorize_super_users_catalog_managers
    # verify that user is either a super user or catalog manager for this service; service providers are not allowed!
    if current_identity.admin_organizations(:su_only => true).include?(@service.organization) || current_identity.can_edit_entity?(@service.organization, true)
      return true
    else
      @service = nil
      render "additional_detail/shared/unauthorized", :status => :unauthorized
    end
  end

end
