class CatalogManager::InstitutionsController < CatalogManager::AppController
  respond_to :js, :html, :json
  layout false

  def create
    @institution = Institution.create({:name => params[:name], :abbreviation => params[:name], :is_available => false})
    @user.catalog_manager_rights.create :organization_id => @institution.id
 
    respond_with [:catalog_manger, @institution]
  end

  def show
    @institution = Institution.find(params[:id])
    @institution.setup_available_statuses
  end

  def update
    @institution = Institution.find(params[:id])
    
    params[:institution].delete(:id)
    if @institution.update_attributes(params[:institution])
      flash[:notice] = "#{@institution.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@institution.name}."
    end
    
    @institution.setup_available_statuses
    @entity = @institution
    respond_with @institution, :location => catalog_manager_institution_path(@institution)
  end
end
