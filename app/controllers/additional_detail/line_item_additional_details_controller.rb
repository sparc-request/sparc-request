class AdditionalDetail::LineItemAdditionalDetailsController < ApplicationController
  protect_from_forgery
  
  layout 'additional_detail/application'

  before_filter :authorize_identity
  
  def show
    
  end

# create a record as part of the service request flow?    
#  def create
#    
#  end
  
  def update
    
  end
end
