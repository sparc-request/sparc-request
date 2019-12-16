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
class CatalogManager::OrganizationsController < CatalogManager::AppController
  layout false

  def new
    if params[:type] == "Institution"
      #Institutions have different parameters
      @organization = Organization.new(type: params[:type])
    else
      ##Check if user has catalog manager rights to the parent of this new org.
      parent_org = Organization.find(params[:parent_id])
      if current_user.can_edit_organization?(parent_org)
        @organization = Organization.new(type: params[:type], parent_id: params[:parent_id])
      else
        flash[:alert] = "You must have catalog manager rights above this level, to create a new organization here."
      end
    end
  end

  def create
    @organization = Organization.new(new_organization_params[:organization])
    if @organization.save
      @organization.create_subsidy_map() unless @organization.type == 'Institution'
      unless current_user.catalog_manager_organizations.include?(@organization)
        current_user.catalog_manager_rights.create(organization_id: @organization.id)
      end

      @institutions = Institution.order('`order`')
      @path = catalog_manager_organization_path(@organization)
      @user_rights  = user_rights(@organization.id)
      @editable_organizations = current_user.catalog_manager_organizations
      @fulfillment_rights = fulfillment_rights(@organization.id)

      flash[:success] = "New Organization created successfully."
    else
      @errors = @organization.errors
    end
  end

  def edit
    @organization = Organization.find(params[:id])
    @user_rights  = user_rights(@organization.id)
    @fulfillment_rights = fulfillment_rights(@organization.id)
    set_status_variables

    respond_to do |format|
      format.js
    end
  end

  def update
    @organization = Organization.find(params[:id])
    @user_rights  = user_rights(@organization.id)
    @fulfillment_rights = fulfillment_rights(@organization.id)
    set_status_variables

    # set_org_tags
    if update_organization
      flash.now[:success] = "#{@organization.name} saved correctly."
    else
      flash.now[:alert] = "Failed to update organization."
      @errors = @organization.errors
    end

    @institutions = Institution.order(Arel.sql('`order`,`name`'))
    @editable_organizations = current_user.catalog_manager_organizations
    @show_available_only = @organization.is_available

    respond_to do |format|
      format.js
    end
  end


  ####Actions for User Rights sub-form####
  def add_user_rights_row
    @organization = Organization.find(params[:organization_id])
    @new_ur_identity = Identity.find(params[:new_ur_identity_id])
    @user_rights  = user_rights(@organization.id)
  end

  def remove_user_rights_row
    su_destroyed = SuperUser.find_by(user_rights_params).try(:destroy)
    cm_destroyed = CatalogManager.find_by(user_rights_params).try(:destroy)
    sp_destroyed = ServiceProvider.find_by(user_rights_params).try(:destroy)

    if su_destroyed or cm_destroyed or sp_destroyed
      @identity_id = user_rights_params[:identity_id]
      flash[:success] = "User rights removed successfully."
    else
      flash[:alert] = "Error removing user rights."
    end
  end


  ####Actions for Fulfillment Rights sub-form####
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
      flash[:success] = "Fulfillment rights removed successfully."
    else
      flash[:alert] = "Error removing fulfillment rights."
    end
  end


  ####Actions for status sub-form####
  def toggle_default_statuses
    @organization = Organization.find(status_params[:organization_id])
    if @organization.update_attributes(use_default_statuses: status_params[:checked])
      flash[:success] = "Organization updated successfully."
    else
      flash[:alert] = "Error updating organization."
    end

    set_status_variables
  end

  def update_status_row
    @status = status_params[:status_type].constantize.find_or_create_by(organization_id: status_params[:organization_id], status: status_params[:status_key])

    @organization = Organization.find(status_params[:organization_id])
    @status_key = @status.status
    @status_value = @status.humanize

    if @status.update_attributes(selected: status_params[:selected])
      flash[:success] = "Status updated successfully."
    else
      flash[:alert] = "Error updating status."
    end
    set_status_variables
  end


  ####Actions for the pricing sub-form####
  def increase_decrease_modal
    @organization = Organization.find(params[:organization_id])
    @can_edit_historical = current_user.can_edit_historical_data_for?(@organization)

  end

  def increase_decrease_rates
    percentage = params[:percent_of_change]
    effective_date = params[:effective_date]
    display_date = params[:display_date]
    @organization = Organization.find(params[:organization_id])
    services = @organization.all_child_services

    services_not_updated = []
    services.each do |service|
      old_effective_dates = service.pricing_maps.map{ |pm| pm.effective_date }
      old_display_dates = service.pricing_maps.map{ |pm| pm.display_date }
      if old_effective_dates.include?(effective_date.to_date) || old_display_dates.include?(display_date.to_date)
        services_not_updated << service.name
      else
        service.increase_decrease_pricing_map(percentage, display_date, effective_date)
      end
    end

    if services_not_updated.empty?
      flash[:success] = "Successfully updated the pricing maps for all of the services under #{@organization.name}."
    else
      flash[:notice] = "Successfully updated the pricing maps for all of the services under #{@organization.name} except for the following: #{services_not_updated.join(', ')}"
    end
  end


  ####Actions for Surveys sub-form####

  def add_associated_survey
    @organization = Organization.find(params[:surveyable_id])
    @associated_survey = @organization.associated_surveys.new :survey_id => params[:survey_id]

    if @associated_survey.save
      flash[:success] = "Survey added successfully."
    else
      @organization.reload
      @associated_survey.errors.messages.each do |field, message|
        flash[:alert] = "Error adding survey: #{message.first}."
      end
    end
  end

  def remove_associated_survey
    associated_survey = AssociatedSurvey.find(params[:associated_survey_id])
    @organization = associated_survey.associable

    if associated_survey.destroy
      @survey_id = associated_survey.id.to_s
      flash[:success] = "Survey deleted successfully."
    else
      @survey_id = nil
      flash[:alert] = "Error deleting survey."
    end
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


  def update_organization
    @attributes = organization_params[:organization]
    @attributes.delete(:id)
    #detects if incoming name/abbreviation is different from the old name/abbreviation
    name_change = @attributes[:name] != @organization.name || @attributes[:abbreviation] != @organization.abbreviation

    if @organization.update_attributes(@attributes)
      @organization.update_ssr_org_name if (@organization.type != "Institution" && name_change)
      update_services
      true
    else
      false
    end
  end

  def update_services
    if @attributes[:is_available] == '0'
      # disable ALL children
      @organization.update_descendants_availability(false)
    elsif params[:all_services_availability] != 'keep'
      # enable immediate child services
      @organization.services.each do |service|
        service.update_attributes(is_available: params[:all_services_availability] == 'true')
      end
    end
  end

  # ================ end ========================

  def organization_params
    params.permit(organization: [
      :name,
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
      submission_emails_attributes: [:organization_id, :email]
      ])
  end

  def new_organization_params
    params.permit(organization: [
      :type,
      :name,
      :is_available,
      :parent_id
      ])
  end

  def fulfillment_rights_params
    params.require(:fulfillment_rights).permit(
      :identity_id,
      :organization_id)
  end

  def user_rights_params
    params.require(:user_rights).permit(
      :identity_id,
      :organization_id
      )
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
