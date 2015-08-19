class AdditionalDetail::ServicesController < ApplicationController
  layout 'additional_detail/application'
    
  before_filter :authenticate_identity!
  
  def index
    # set up a page to select from available services??
  end
  

end
