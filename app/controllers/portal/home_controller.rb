class Portal::HomeController < Portal::BaseController
  respond_to :html, :json

  def index
    respond_with @user
  end
end
