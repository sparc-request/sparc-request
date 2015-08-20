class AdditionalDetail::AdditionalDetailsController < ApplicationController
  protect_from_forgery
  
  layout 'additional_detail/application'
    
  before_filter :authenticate_identity!
  before_filter :load_service_and_authorize_user
  
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @service.additional_details }
    end
  end
  
  def show
    render :json => @service.additional_details.find(params[:id])
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
  
  def update
    @additional_detail = @service.additional_details.find(params[:id])
    if @additional_detail.update_attributes(params[:additional_detail])
      # success page or success JSON response
    end
  end

  def destroy
    @additional_detail = @service.additional_details.find(params[:id])
    if @additional_detail.destroy
      # success page or success JSON response
    end
  end
  
  private
  
  def load_service_and_authorize_user
    @service = Service.find(params[:service_id])
    # verify that user is either a super user or catalog manager for this service; service providers are not allowed!
    if current_identity.admin_organizations(:su_only => true).include?(@service.organization) || current_identity.can_edit_entity?(@service.organization, true)
      return true
    else
      @service = nil
      # @TODO: render JSON authorized message??
      render "unauthorized", :status => :unauthorized
    end
  end
  
end
