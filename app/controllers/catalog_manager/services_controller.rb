class CatalogManager::ServicesController < CatalogManager::ApplicationController
  layout false
  respond_to :js, :html, :json

  def show
    @service = Service.find params[:id]
    @programs = @service.provider.programs
    @cores = @service.program.cores
  end

  def update_cores
    @cores = Program.find(params[:id]).cores
  end

  def new
    if params[:parent_object_type] == 'program'
      @program = Program.find params[:parent_id]
      @entity = @program
      @programs = @program.provider.programs
      @cores = @program.cores
    elsif params[:parent_object_type] == 'core'
      @core = Core.find params[:parent_id]
      @entity = @core
      @program = @core.program
      @programs = @program.provider.programs
      @cores = @program.cores
    else
      @programs = Program.all
      @cores = Core.all
    end
    @service = @entity.services.build({:name => 'New Service', :abbreviation => 'New Service'})

  end

  def create
    if params[:service][:core] && params[:service][:core] != '0'
      @core = Core.find(params[:service][:core])
      @service = @core.services.build(params[:service])      
    elsif params[:service][:program]
      @program = Program.find(params[:service][:program])
      @service = @program.services.build(params[:service])      
    else
      @service = Service.new(params[:service])      
    end
    
    # This will correctly map the service.organization if a user changes the core of the service.
    unless params[:service][:core].blank? && params[:service][:program].blank?
      orgid = params[:service][:program]
      orgid = params[:service][:core] unless (params[:service][:core].blank? || params[:service][:core] == '0')
      unless @service.organization.id.to_s == orgid.to_s
        new_org = Organization.find(orgid)
        @service.update_attribute(:organization_id, orgid) if new_org
      end
    end     

    # @service.pricing_maps.build(params[:pricing_map]) if params[:pricing_map]
    params[:pricing_maps].each do |pm|
      pm[1][:full_rate] = Service.dollars_to_cents(pm[1][:full_rate]) unless pm[1][:full_rate].blank?
      pm[1][:federal_rate] = Service.dollars_to_cents(pm[1][:federal_rate]) unless pm[1][:federal_rate].blank?
      pm[1][:corporate_rate] = Service.dollars_to_cents(pm[1][:corporate_rate]) unless pm[1][:corporate_rate].blank?
      pm[1][:other_rate] = Service.dollars_to_cents(pm[1][:other_rate]) unless pm[1][:other_rate].blank?
      pm[1][:member_rate] = Service.dollars_to_cents(pm[1][:member_rate]) unless pm[1][:member_rate].blank?
      @service.pricing_maps.build(pm[1])
    end if params[:pricing_maps]
    
    if params[:cancel]
      render :action => 'cancel'
    else
      @service.save!
      @programs = @service.provider.programs
      @cores = @service.program.cores
      respond_with @service, :location => services_path(@service)
    end
  end

  def update
    @service = Service.find(params[:id])
    saved = false
    
    program = params[:service][:program]
    core = params[:service][:core]

    params[:service].delete(:id)
    params[:service].delete(:program)
    params[:service].delete(:core)    
    
    saved = @service.update_attributes(params[:service])
    
    # This will update the service.organization if a user changes the core of the service.
    unless core.blank? && program.blank?
      orgid = program
      orgid = core unless (core.blank? || core == '0')    
      unless @service.organization.id.to_s == orgid.to_s
        new_org = Organization.find(orgid)
        @service.update_attribute(:organization_id, orgid) if new_org
      end
    end       

    params[:pricing_maps].each do |pm|
      pm[1][:full_rate] = Service.dollars_to_cents(pm[1][:full_rate]) unless pm[1][:full_rate].blank?
      pm[1][:federal_rate] = Service.dollars_to_cents(pm[1][:federal_rate]) unless pm[1][:federal_rate].blank?
      pm[1][:corporate_rate] = Service.dollars_to_cents(pm[1][:corporate_rate]) unless pm[1][:corporate_rate].blank?
      pm[1][:other_rate] = Service.dollars_to_cents(pm[1][:other_rate]) unless pm[1][:other_rate].blank?
      pm[1][:member_rate] = Service.dollars_to_cents(pm[1][:member_rate]) unless pm[1][:member_rate].blank?
      if pm[1]['id'] == 'blank'
        @service.pricing_maps.build(pm[1])
      else
        # saved = @service.pricing_maps.find(pm[1]['id']).update_attributes(pm[1])	
        pm_id = pm[1]['id']
        pm[1].delete(:id)
        saved = @service.pricing_maps.find(pm_id).update_attributes(pm[1])        
      end
      if saved == true
        saved = @service.save
      else
        @service.save
      end
    end if params[:pricing_maps]

    # past_maps = @service.pricing_maps.inject([]) do |arr, pm|
    #   arr << pm if Date.parse(pm['effective_date']) < Date.today
    #   arr
    # end     
    if saved
      flash[:notice] = "#{@service.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@service.name}."
    end

    @entity = @service
    respond_with @service, :location => service_path(@service)
  end

  def associate
    service_id         = params["service"]
    related_service_id = params["related_service"]

    os = Service.find service_id
    rs = Service.find related_service_id

    if not os.related_services or (os.related_services and not os.related_services.map{|x| x['service'].id}.include? related_service_id)
      os.create_relationship_to rs.id, 'associated_service', {"optional" => false}
    end

    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => os}
  end

  def disassociate
    service_id = params["service"]
    rel_id     = params["rel_id"]

    os = Service.find service_id

    os.destroy_relationship_with rel_id

    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => os}
  end

  def set_optional
    rel_id        = params["rel_id"]
    optional_flag = params["optional_flag"]

    optional_flag = optional_flag == "true"

    atts = {:optional => optional_flag == false}

    @rel = {
      'relationship_type' => 'associated_service',
      'attributes'        => atts,
      'from'              => params["service"],
      'to'                => params["related_service"]
    }

    os = Service.find params["service"]

    os.update_relationship rel_id, @rel

    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => os}
  end

  def search
    services = Service.search params[:term]
    reformatted_services = []
    services.each do |service|
      reformatted_services << {"label" => service.display_name, "value" => service.name, "id" => service.id}
    end
    respond_with [:catalog_manager, reformatted_services.to_json]
    #respond_with [{"label" => "Andrew", "value" => "Cates", "id" => 123}].to_json
  end
  
  def get_updated_rate_maps
    new_rate = PricingMap.rates_from_full(params[:date].try(:to_date).try(:strftime, "%F"), params[:organization_id], Service.dollars_to_cents(params[:full_rate]))
    new_rate["federal_rate"] = Service.fix_service_rate(new_rate.try(:[], :federal_rate))
    new_rate["corporate_rate"] = Service.fix_service_rate(new_rate.try(:[], :corporate_rate))
    new_rate["other_rate"] = Service.fix_service_rate(new_rate.try(:[], :other_rate))
    new_rate["member_rate"] = Service.fix_service_rate(new_rate.try(:[], :member_rate))
    render :json => new_rate.to_json
  end

  private

  

end
