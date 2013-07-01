class ProtocolsController < ApplicationController
  before_filter :initialize_service_request
  before_filter :authorize_identity
  before_filter :set_protocol_type

  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = self.model_class.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = self.model_class.new(params[:study] || params[:project])

    if @protocol.valid?
      @protocol.save
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "New #{@protocol.type.downcase} created"
    else
      # TODO: Is this neccessary?
      @protocol.populate_for_edit
    end
  end

  def edit
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = current_user.protocols.find params[:id]
    @protocol.populate_for_edit
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = current_user.protocols.find params[:id]

    if @protocol.update_attributes(params[:study] || params[:project])
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "#{@protocol.type.humanize} updated"
    end
      
    @protocol.populate_for_edit
  end

  def destroy

  end

  def set_protocol_type
    raise NotImplementedError
  end
end
