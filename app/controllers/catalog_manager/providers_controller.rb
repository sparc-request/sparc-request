class CatalogManager::ProvidersController < CatalogManager::AppController
  respond_to :js, :html, :json  
  layout false

  def create
    @institution = Institution.find(params[:institution_id])
    @provider = Provider.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @institution.id})
    @provider.build_subsidy_map()
    @provider.save
    
    respond_with [:catalog_manger, @provider]
  end

  def show
    @provider = Provider.find(params[:id])
    @provider.setup_available_statuses
  end

  def update
    @provider = Provider.find(params[:id])

    params[:provider].delete(:id)    
    if @provider.update_attributes(params[:provider])
      flash[:notice] = "#{@provider.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@provider.name}."
    end
    
    params[:pricing_setups].each do |ps|
      if ps[1]['id'] == 'blank'
        ps[1].delete(:id)
        ps[1].delete(:newly_created)
        @provider.pricing_setups.build(ps[1])
      else
        # @provider.pricing_setups.find(ps[1]['id']).update_attributes(ps[1])
        ps_id = ps[1]['id']
        ps[1].delete(:id)
        @provider.pricing_setups.find(ps_id).update_attributes(ps[1])        
      end
      @provider.save
    end if params[:pricing_setups]

    @provider.setup_available_statuses
    @entity = @provider
    respond_with @provider, :location => catalog_manager_provider_path(@provider)
  end

end
