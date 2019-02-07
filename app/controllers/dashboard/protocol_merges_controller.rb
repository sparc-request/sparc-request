class Dashboard::ProtocolMergesController < Dashboard::BaseController
  respond_to :json, :html

  def show
    @user = current_identity
  end

end