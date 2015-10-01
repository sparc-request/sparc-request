class AdditionalDetail::LineItemAdditionalDetailsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_identity!
  before_filter :load_line_item_additional_detail_and_authorize_user
  
  def show
     render :json => @line_item_additional_detail
  end

#  def update
    
 # end
  
  private
  
  def load_line_item_additional_detail_and_authorize_user
    @line_item_additional_detail = LineItemAdditionalDetail.find(params[:id])
    # verify that user is either a super user or service provider for this service; catalog managers are not allowed!
    if current_identity.admin_organizations(:su_only => false).include?(@line_item_additional_detail.line_item.service.organization) 
      return true
    # next, try to verify that the user is either the original service requestor or a team member on the project 
    elsif true
      return true
    else
      @line_item_additional_detail = nil
      render :json => "", :status => :unauthorized
    end
  end
end
