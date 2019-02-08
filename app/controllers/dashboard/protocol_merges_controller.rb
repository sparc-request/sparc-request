class Dashboard::ProtocolMergesController < Dashboard::BaseController
  respond_to :json, :html

  def show
    @user = current_identity
  end

  def perform_protocol_merge
    master_protocol = Protocol.find(params[:master_protocol_id].to_i)
    sub_protocol = Protocol.find(params[:sub_protocol_id].to_i)

    
    # flash[:alert] = 'Approval Submitted!'
  end

end