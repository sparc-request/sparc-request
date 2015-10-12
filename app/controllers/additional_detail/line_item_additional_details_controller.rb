class AdditionalDetail::LineItemAdditionalDetailsController < ApplicationController
  protect_from_forgery
  before_filter :authenticate_identity!
  before_filter :load_line_item_additional_detail_and_protocol
  before_filter :protocol_authorizer_view, :only => [:show]
  before_filter :protocol_authorizer_edit, :only => [:update]

  
  def show
     render :json => @line_item_additional_detail
  end

  def update
    if @line_item_additional_detail.update_attributes(params[:line_item_additional_detail])
      head :no_content
    else
      render json: @line_item_additional_detail.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def load_line_item_additional_detail_and_protocol
    @line_item_additional_detail = LineItemAdditionalDetail.where(id: params[:id]).first()
    if !@line_item_additional_detail 
      render :json => "", :status => :not_found
    else
      @protocol = @line_item_additional_detail.line_item.service_request.protocol
    end
  end
  # verify that a user is a team member on the project
  # or, a super user or service provider for this service
  # but catalog managers are not allowed!
  def protocol_authorizer_view
    authorized_user = ProtocolAuthorizer.new(@protocol, current_identity)
    if !authorized_user.can_view?
      render :json => "", :status => :unauthorized
    end
  end

  def protocol_authorizer_edit
    authorized_user = ProtocolAuthorizer.new(@protocol, current_identity)
    if !authorized_user.can_edit?
      render :json => "", :status => :unauthorized
    end
  end
end
