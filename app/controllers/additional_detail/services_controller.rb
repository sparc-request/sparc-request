class AdditionalDetail::ServicesController < ApplicationController
  protect_from_forgery
  
  layout 'additional_detail/application'
    
  before_filter :authenticate_identity!
  
  def index
    # set up a page to select from available services??
  end
  
  def show
    @service = Service.find(params[:id])
    render :json => @service.to_json(:root => false, :include => :current_additional_detail)
  end

end
