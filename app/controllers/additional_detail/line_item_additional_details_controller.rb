class AdditionalDetail::LineItemAdditionalDetailsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_identity!
  before_filter :load_line_item_additional_detail_and_authorize_user
  
  def show
     render :json => @line_item_additional_detail
  end

  def update
    @line_item_additional_detail = LineItemAdditionalDetail.find(params[:id])
    puts :jdkleqwjfklqjss
      puts params[:line_item_additional_detail]
    @line_item_additional_detail.update_attributes(params[:line_item_additional_detail])
    head :no_content
  end
  
  private
  
  def load_line_item_additional_detail_and_authorize_user
    @line_item_additional_detail = LineItemAdditionalDetail.where(id: params[:id]).first()
    if !@line_item_additional_detail 
      render :json => "", :status => :not_found
    # verify that user is either a super user or service provider for this service; catalog managers are not allowed!
#    elsif current_identity.admin_organizations(:su_only => false).include?(@line_item_additional_detail.line_item.service.organization) 
#      return true
    # next, try to verify that the user is either the original service requestor or a team member on the project 
    elsif ServiceRequest.where(:id => @line_item_additional_detail.line_item.service_request_id, :service_requester_id => current_identity.id).first
      return true
    else
      @line_item_additional_detail = nil
      render :json => "", :status => :unauthorized
    end
  end
end
