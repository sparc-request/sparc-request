class Dashboard::ProtocolMergesController < Dashboard::BaseController
  respond_to :json, :html

  def show
    @user = current_identity
  end

  def perform_protocol_merge
    master_protocol = Protocol.where(id: params[:master_protocol_id].to_i).first
    sub_protocol = Protocol.where(id: params[:sub_protocol_id].to_i).first

    if (master_protocol == nil) || (sub_protocol == nil)
      flash[:alert] = 'Protocol(s) not found. Check IDs and try again.'
    end 
  end
end