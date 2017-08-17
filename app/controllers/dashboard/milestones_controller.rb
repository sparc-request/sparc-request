class Dashboard::MilestonesController < Dashboard::BaseController

  def update
    @protocol = Protocol.find(params[:protocol_id])
    @protocol.update_attributes(protocol_params)
    respond_to do |format|
      format.js
    end
  end

  private

  def protocol_params
    params.require(@protocol.type.downcase.to_sym).permit(
      :start_date,
      :end_date,
      :recruitment_start_date,
      :recruitment_end_date
    )
  end
end

