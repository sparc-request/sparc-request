class ResearchMastersController < ApplicationController
  #RMID will send a token to this controller action, preventing any other
  #accessibility to this route
  before_action :restrict_access


  def update
    @protocol = Protocol.find(params[:protocol_id])
    #currently, this route is only used when an RMID is deleted, thus we set it
    #to nil
    @protocol.update_attribute(:research_master_id, nil)
    head :ok
  end

  private

  def restrict_access
    api_key = Setting.find_by(key: 'research_master_api_token').value == params[:access_token]
    head :unauthorized unless api_key
  end
end

