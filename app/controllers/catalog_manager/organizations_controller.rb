# Copyright © 2011-2018 MUSC Foundation for Research Development
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
class CatalogManager::OrganizationsController < CatalogManager::AppController
  layout false

  def new
     @organization = Organization.new
  end

  def create
    @organization.build_subsidy_map() unless @organization.type == 'Institution'
    @organization.save
  end

  def edit
    @organization = Organization.find(params[:id])
    @user_rights  = user_rights(@organization.id)
    @fulfillment_rights = fulfillment_rights(@organization.id)
    set_status_variables

    respond_to do |format|
      format.js
    end

    #TODO: Validate user can edit organization
    render 'catalog_manager/organizations/edit'
  end

  def update
    @organization = Organization.find(params[:id])
    @user_rights  = user_rights(@organization.id)

    set_org_tags
    if update_organization
      flash.now[:success] = "#{@organization.name} saved correctly."
    else
      flash.now[:alert] = "Failed to update #{@organization.name}."
    end
    save_pricing_setups

    @institutions = Institution.order('`order`')

    respond_to do |format|
      format.js
    end

    render 'catalog_manager/organizations/update'
  end


  ##Actions for User Rights sub-form##
  def add_user_rights_row
    @organization = Organization.find(params[:organization_id])
    @new_ur_identity = Identity.find(params[:new_ur_identity_id])
    @user_rights  = user_rights(@organization.id)
  end


  ##Actions for Fulfillment Rights sub-form##
  def add_fulfillment_rights_row
    @organization = Organization.find(params[:organization_id])
    @new_fr_identity = Identity.find(params[:new_fr_identity_id])
    @fulfillment_rights = fulfillment_rights(@organization_id)
  end

  def remove_fulfillment_rights_row
    cp_destroyed = ClinicalProvider.find_by(fulfillment_rights_params).try(:destroy)
    ##Invoicer support, uncomment when needed:
    # iv_destroyed = Invoicer.find_by(fulfillment_rights_params).try(:destroy)

    if cp_destroyed# or iv_destroyed
      @identity_id = fulfillment_rights_params[:identity_id]
      flash[:notice] = "Fulfillment rights removed successfully."
    else
      flash[:alert] = "Error removing fulfillment rights."
    end
  end


  ##Actions for status sub-form##
  def toggle_default_statuses
    @organization = Organization.find(status_params[:organization_id])
    if @organization.update_attributes(use_default_statuses: status_params[:checked])
      flash[:notice] = "Organization updated successfully."
    else
      flash[:alert] = "Error updating organization."
    end

    set_status_variables
  end

  def update_status_option
    @status = status_params[:status_type].constantize.find_or_create_by(organization_id: status_params[:organization_id], status: status_params[:status_key])

    @organization = Organization.find(status_params[:organization_id])
    @status_key = @status.status
    @status_value = @status.humanize

    if @status.update_attributes(selected: status_params[:selected])
      flash[:notice] = "Status updated successfully."
    else
      flash[:alert] = "Error updating status."
    end
    set_status_variables
  end

  private

  def set_status_variables
    if @organization.use_default_statuses
      @available_statuses = AvailableStatus.defaults
    else
      @available_statuses = @organization.available_statuses
      @editable_statuses = @organization.editable_statuses
    end
    @using_defaults = @organization.use_default_statuses
  end

  # ================ Imported from OrganizationUpdater ========================

  def set_org_tags
    unless @attributes[:tag_list] || @organization.type == 'Institution'
      @attributes[:tag_list] = ""
    end
  end

  def update_organization
    @attributes.delete(:id)
    #detects if incoming name/abbreviation is different from the old name/abbreviation
    name_change = @attributes[:name] != @organization.name || @attributes[:abbreviation] != @organization.abbreviation

    if @organization.update_attributes(@attributes)
      @organization.update_ssr_org_name if name_change
      update_services
      true
    else
      false
    end
  end

  def save_pricing_setups
    if params[:pricing_setups] && ['Program', 'Provider'].include?(@organization.type)
      params[:pricing_setups].each do |_, ps|
        if ps['id'].blank?
          ps.delete("id")
          ps.delete("newly_created")
          @organization.pricing_setups.build(pricing_setups_params(pricing_setups_params(ps)))
        else
          # @organization.pricing_setups.find(ps['id']).update_attributes(ps)
          ps_id = ps['id']
          ps.delete("id")
          @organization.pricing_setups.find(ps_id).update_attributes(pricing_setups_params(ps))
        end
        @organization.save
      end
    end
  end

  def update_services
    if @attributes[:is_available] == '0'
      # disable ALL children
      @organization.update_descendants_availability(false)
    elsif params[:all_services_availability] != 'keep'
      # enable immediate child services
      @organization.services.update_all(is_available: params[:all_services_availability] == 'true')
    end
  end

  # ================ end ========================

  def organization_params(type)
    params.require(type).permit(:name,
      :order,
      :css_class,
      :description,
      :parent_id,
      :abbreviation,
      :ack_language,
      :process_ssrs,
      :is_available,
      :use_default_statuses,
      { tag_list:  [] },
      subsidy_map_attributes: [:organization_id,
        :max_dollar_cap,
        :max_percentage,
        :default_percentage,
        :instructions],
      pricing_setups_attributes: [:organization_id,
        :display_date,
        :effective_date,
        :charge_master,
        :federal,
        :corporate,
        :other,
        :member,
        :college_rate_type,
        :federal_rate_type,
        :foundation_rate_type,
        :industry_rate_type,
        :investigator_rate_type,
        :internal_rate_type,
        :unfunded_rate_type],
      submission_emails_attributes: [:organization_id, :email],
      available_statuses_attributes: [:organization_id,
        :id,
        :status,
        :selected],
      editable_statuses_attributes: [:organization_id,
        :id,
        :status,
        :selected])
  end

  def pricing_setups_params(ps)
    ps.permit(:organization_id,
      :display_date,
      :effective_date,
      :charge_master,
      :federal,
      :corporate,
      :other,
      :member,
      :college_rate_type,
      :federal_rate_type,
      :foundation_rate_type,
      :industry_rate_type,
      :investigator_rate_type,
      :internal_rate_type,
      :unfunded_rate_type)
  end

  def fulfillment_rights_params
    params.require(:fulfillment_rights).permit(
      :identity_id,
      :organization_id)
  end

  def status_params
    params.permit(
      :organization_id,
      :checked,
      :status_key,
      :selected,
      :status_type)
  end
end
