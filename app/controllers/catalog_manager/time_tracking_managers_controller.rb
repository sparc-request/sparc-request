class CatalogManager::TimeTrackingManagersController < CatalogManager::AppController

  def create
    @time_tracking_manager = TimeTrackingManager.new(time_tracking_manager_params)
    @identity = Identity.find(@time_tracking_manager.identity_id)
    @organization = @time_tracking_manager.organization
    set_registrar_enabled(@organization)
    @fulfillment_rights = fulfillment_rights(@organization.id)

    if @time_tracking_manager.save
      flash[:notice] = "Time Tracking Manager created successfully."
    else
      @time_tracking_manager.errors.messages.each do |field, message|
        flash[:alert] = "Error adding Time Tracking Manager: #{message.first}."
      end
    end

    render 'catalog_manager/organizations/refresh_fulfillment_rights_row'
  end

  def destroy
    @time_tracking_manager = TimeTrackingManager.find_by(time_tracking_manager_params)
    @identity = Identity.find(@time_tracking_manager.identity_id)
    @organization = @time_tracking_manager.organization
    set_registrar_enabled(@organization)
    @fulfillment_rights = fulfillment_rights(@organization.id)

    if @time_tracking_manager.destroy
      flash[:notice] = "Time Tracking Manager removed successfully."
    else
      flash[:alert] = "Error removing Time Tracking Manager."
    end

    render 'catalog_manager/organizations/refresh_fulfillment_rights_row'
  end

  private

  def time_tracking_manager_params
    params.require(:time_tracking_manager).permit(
      :identity_id,
      :organization_id)
  end
end
