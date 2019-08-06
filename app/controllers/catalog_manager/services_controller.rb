# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  respond_to :html, :json, except: :edit

  def new
    parent_org = Organization.find(params[:organization_id])
    if @user.can_edit_organization?(parent_org)
      @service = Service.new(organization_id: params[:organization_id])
    else
      flash[:alert] = "You must have catalog manager rights to the parent organization. to create a new service."
    end
  end

  def create
    @service = Service.new(service_params)

    if @service.save
      @programs = @service.provider.programs
      @cores    = @service.program.cores
      @institutions = Institution.order('`order`')
      @editable_organizations = @user.catalog_manager_organizations
      flash[:success] = "New Service created successfully."
    else
      @errors = @service.errors
    end
  end

  def edit
    @service  = Service.find params[:id]
    @programs = @service.provider.programs
    @cores    = @service.program.cores

    #TODO: Validate user can edit service
    respond_to do |format|
      format.js
    end
  end

  def update
    @service = Service.find(params[:id])

    program = service_params[:program]
    core = service_params[:core]

    # This will update the service.organization if a user changes the core of the service.
    unless core.blank? && program.blank?
      orgid = program
      orgid = core unless (core.blank? || core == '0')
      unless @service.organization.id.to_s == orgid.to_s
        new_org = Organization.find(orgid)
        @service.update_attribute(:organization_id, orgid) if new_org
      end
    end

    if @service.update_attributes(service_params.except(:program, :core))
      flash[:success] = "#{@service.name} saved correctly."
      @institutions = Institution.order('`order`')
      @editable_organizations = @user.catalog_manager_organizations
    else
      flash[:alert] = "Failed to update service."
      @errors = @service.errors
    end

    @service.reload
    @programs = @service.provider.programs
    @cores    = @service.program.cores
    @show_available_only = @service.is_available
  end

  ####Service Components Methods####

  def change_components
    @service = Service.find(params[:service_id])
    component = service_params[:component]
    components_list = (@service.components ? @service.components.split(',') : [])

    if components_list.include?(component)
      #Delete component from list and save updated list
      components_list.delete(component)
      if @service.update_attribute(:components, components_list.join(','))
        flash[:success] = "Component deleted successfully."
      else
        flash[:alert] = "Error deleting component."
      end
    else
      #Add new component to list and save updated list
      components_list.push(component)
      if @service.update_attribute(:components, components_list.join(','))
        flash[:success] = "New component saved successfully."
      else
        flash[:alert] = "Failed to create new component."
      end
    end

    respond_to do |format|
      format.js
    end
  end

  ####Epic Info Methods####

  def update_epic_info
    @service = Service.find(params[:service_id])

    if @service.update_attributes(service_params)
      flash[:success] = "#{@service.name} saved successfully."
    else
      flash[:alert] = "Error updating #{@service.name}."
    end

    respond_to do |format|
      format.js
    end
  end

  ####Related Services Methods####

  def add_related_service
    @service = Service.find(params[:service_id])
    related_service = Service.find(params[:related_service_id])
    @service_relation = @service.service_relations.new(related_service_id: related_service.id, required: true)

    if @service_relation.save
      flash[:success] = "Related service added successfully."
    else
      flash[:alert] = "Error creating new related service."
    end
  end

  def update_related_service
    @service_relation = ServiceRelation.find(params[:service_relation_id])
    @service = @service_relation.service

    if @service_relation.update_attributes(service_relation_params)
      flash[:success] = "Related service updated successfully."
    else
      flash[:alert] = "Error updating related service."
    end
  end

  def remove_related_service
    @service_relation = ServiceRelation.find(params[:service_relation_id])

    if @service_relation.destroy
      flash[:success] = "Related service removed successfully."
    else
      flash[:alert] = "Error removing related service."
    end
  end

  ####Search####

  def search
    term = params[:term].strip
    services = Service.where("is_available=1 AND (name LIKE '%#{term}%' OR abbreviation LIKE '%#{term}%' OR cpt_code LIKE '%#{term}%')")
    reformatted_services = []
    services.each do |service|
      reformatted_services << {"label" => service.display_service_name, "value" => service.name, "id" => service.id}
    end

    render :json => reformatted_services.to_json
  end


  ####General Methods####

  def reload_core_dropdown
    @service = Service.find(params[:service_id])
    @cores = Program.find(params[:program_id]).cores
  end

  private

  def service_params
    params.require(:service).permit(
      :program,
      :core,
      :name,
      :abbreviation,
      :order,
      :description,
      :is_available,
      :service_center_cost,
      :cpt_code,
      :eap_id,
      :charge_code,
      :order_code,
      :revenue_code,
      :organization_id,
      :send_to_epic,
      { tag_list: [] },
      :revenue_code_range_id,
      :line_items_count,
      :one_time_fee,
      :component
    )
  end

  def service_relation_params
    params.require(:service_relation).permit(
      :required
    )
  end
end
