class CatalogManager::ProgramsController < CatalogManager::AppController
  respond_to :js, :html, :json
  layout false

  def create
    @provider = Provider.find(params[:provider_id])
    @program = Program.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @provider.id})
    @program.build_subsidy_map()
    @program.setup_available_statuses
    @program.save
    
    respond_with [:catalog_manager, @program]
  end

  def show
    @organization = Organization.find params[:id]
    @program = Program.find params[:id]
    @program.setup_available_statuses
  end
  
  def update
    @program = Program.find(params[:id])

    params[:program].delete(:id)

    if @program.update_attributes(params[:program])
      flash[:notice] = "#{@program.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@program.name}."
    end
    
    params[:pricing_setups].each do |ps|
      if ps[1]['id'] == 'blank'
        ps[1].delete(:id)
        ps[1].delete(:newly_created)
        @program.pricing_setups.build(ps[1])
      else
        ps_id = ps[1]['id']
        ps[1].delete(:id)
        @program.pricing_setups.find(ps_id).update_attributes(ps[1])        
      end
      @program.save
    end if params[:pricing_setups]
  
    @program.setup_available_statuses      
    @entity = @program
    respond_with @program, :location => catalog_manager_program_path(@program)
  end

end
