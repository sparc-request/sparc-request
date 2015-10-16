class ProtocolArchiveController < ApplicationController
  def create
  	@protocol = Protocol.find(params[:protocol_id])
  	@protocol.toggle!(:archived)
  	respond_to do |format|
      format.js
  	end
  end
end
