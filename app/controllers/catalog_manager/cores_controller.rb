class CatalogManager::CoresController < CatalogManager::AppController
  layout false
  respond_to :js, :html
  
  def create
    @program = Program.find(params[:program_id])
    @core = Core.new({:name => params[:name], :abbreviation => params[:name], :parent_id => @program.id})
    @core.build_subsidy_map()
    @core.save
    
    respond_with [:catalog_manager, @core]
  end
  
  def show
    @core = Core.find(params[:id])
  end
  
  def update
    @core = Core.find(params[:id])

    params[:core].delete(:id)
    if @core.update_attributes(params[:core])
      flash[:notice] = "#{@core.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@core.name}."
    end
    
    @entity = @core
    respond_with @core, :location => catalog_manager_core_path(@core)          
  end
  
  def destroy
    @core = Core.find(params[:id])
    @entity = @core
    if @core.delete
      flash[:notice] = "#{@core.name} deleted correctly."
    else
      flash[:alert] = "Failed to delete #{@core.name}."
    end
    respond_with [:catalog_manager, @core]
  end
  
end
