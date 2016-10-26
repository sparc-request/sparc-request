# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class CatalogManager::ServicesController < CatalogManager::AppController
  layout false
  respond_to :js, :html, :json

  def show
    @service  = Service.find params[:id]
    @programs = @service.provider.programs
    @cores    = @service.program.cores
  end

  def update_cores
    @cores = Program.find(params[:id]).cores
  end

  def new
    if params[:parent_object_type] == 'program'
      @program  = Program.find params[:parent_id]
      @entity   = @program
      @programs = @program.provider.programs
      @cores    = @program.cores
    elsif params[:parent_object_type] == 'core'
      @core     = Core.find params[:parent_id]
      @entity   = @core
      @program  = @core.program
      @programs = @program.provider.programs
      @cores    = @program.cores
    else
      @programs = Program.all
      @cores    = Core.all
    end

    service_attributes = {
      name: "New Service",
      abbreviation: "New Service",
      organization_id: @entity.id
    }

    @service = Service.new(service_attributes)
  end

  def create
    if params[:service][:core] && params[:service][:core] != '0'
      organization = Core.find(params[:service][:core])

      params[:service].delete(:program)
      params[:service].delete(:core)
    elsif params[:service][:program]
      organization = Program.find(params[:service][:program])

      params[:service].delete(:program)
      params[:service].delete(:core)
    end

    service_attributes = params[:service].merge!(organization_id: organization.id)

    @service = Service.new(service_attributes)

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
      @service.save
      @programs = @service.provider.programs
      @cores = @service.program.cores
      respond_with @service, :location => catalog_manager_services_path(@service)
    end
  end

  def update
    @service = Service.find(params[:id])
    saved = false

    unless params[:service][:tag_list]
      params[:service][:tag_list] = ""
    end

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

      if pm[1]['id'].blank?
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

    @service.reload
    @entity = @service
    respond_with @service, :location => catalog_manager_service_path(@service)
  end

  def associate

    service = Service.find params["service"]
    related_service = Service.find params["related_service"]

    if not service.related_services.include? related_service
      service.service_relations.create :related_service_id => related_service.id, :optional => false
    end

    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => service}
  end

  def disassociate
    service_relation = ServiceRelation.find params[:service_relation_id]
    service = service_relation.service

    service_relation.destroy

    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => service}
  end

  def set_optional
    service_relation = ServiceRelation.find params[:service_relation_id]
    service = service_relation.service

    service_relation.update_attribute(:optional, params[:optional])
    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => service}
  end

  def set_linked_quantity
    service_relation = ServiceRelation.find params[:service_relation_id]
    service = service_relation.service

    service_relation.update_attributes(:linked_quantity => params[:linked_quantity], :linked_quantity_total => nil)
    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => service}
  end

  def set_linked_quantity_total
    service_relation = ServiceRelation.find params[:service_relation_id]
    service = service_relation.service

    service_relation.update_attribute(:linked_quantity_total, params[:linked_quantity_total])
    render :partial => 'catalog_manager/shared/related_services', :locals => {:entity => service}
  end

  def search
    term = params[:term].strip
    services = Service.where("name LIKE '%#{term}%' OR abbreviation LIKE '%#{term}%' OR cpt_code LIKE '%#{term}%'")

    reformatted_services = []
    services.each do |service|
      reformatted_services << {"label" => service.display_service_name, "value" => service.name, "id" => service.id}
    end

    render :json => reformatted_services.to_json
  end

  def get_updated_rate_maps
    new_rate = PricingMap.rates_from_full(params[:date].try(:to_date).try(:strftime, "%F"), params[:organization_id], Service.dollars_to_cents(params[:full_rate]))
    new_rate["federal_rate"] = Service.fix_service_rate(new_rate.try(:[], :federal_rate))
    new_rate["corporate_rate"] = Service.fix_service_rate(new_rate.try(:[], :corporate_rate))
    new_rate["other_rate"] = Service.fix_service_rate(new_rate.try(:[], :other_rate))
    new_rate["member_rate"] = Service.fix_service_rate(new_rate.try(:[], :member_rate))
    render :json => new_rate.to_json
  end

  def verify_parent_service_provider
    alert_text = ""
    if params[:parent_object_type] == 'program'
      @org = Program.find params[:parent_id]
      @program = @org
    elsif params[:parent_object_type] == 'core'
      @org = Core.find params[:parent_id]
      @program = @org.program
    end

    if @org.all_service_providers(false).size < 1
      alert_text << "There needs to be at least one service provider on a parent organization to create a new service. "
    end

    if @program && !@program.has_active_pricing_setup
      alert_text << "Before creating services, please configure an active pricing setup for either the program '" << @program.name << "' or the provider '" << @program.provider.name << "'."
    end

    render :text => alert_text
  end

end
