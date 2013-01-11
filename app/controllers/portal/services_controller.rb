class Portal::ServicesController < Portal::BaseController
  # TODO: this method does not work
  def show
    @service = Service.find_by_id_and_service_id_and_status(params[:id], params[:service_id], params[:status])
    respond_to do |format|
      format.js
    end
  end
end
