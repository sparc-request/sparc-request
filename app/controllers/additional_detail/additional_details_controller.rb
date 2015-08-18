class AdditionalDetail::AdditionalDetailsController < ApplicationController
  layout 'additional_detail/application'
  
  def index
    
  end
  
  def new
    @additional_detail = AdditionalDetail.new
    
  end
end
