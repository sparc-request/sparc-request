class ProtocolArchiveController < ApplicationController
  def create
  	@protocol = Protocol.find(params[:protocol_id])
  	@protocol.toggle!(:archived)
  end
end
