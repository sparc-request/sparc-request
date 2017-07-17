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
class CatalogManager::OrganizationsController < CatalogManager::AppController
  layout false
  respond_to :js, :html, :json

  def create
    @organization.build_subsidy_map() unless @organization.type == 'Institution'
    @organization.save
  end

  def show
    @organization = Organization.find(params[:id])
    @organization.setup_available_statuses
    render 'catalog_manager/organizations/show'
  end

  def update
    @organization = Organization.find(params[:id])
    updater = OrganizationUpdater.new(@attributes, @organization, params)
    @attributes = updater.set_org_tags
    show_success = updater.update_organization
    updater.save_pricing_setups
    @organization.setup_available_statuses
    @entity = @organization
    flash_update(show_success)
    render 'catalog_manager/organizations/update'
  end

  private

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
        :status,
        :new,
        :position,
        :_destroy],
      editable_statuses_attributes: [:organization_id,
        :status,
        :new,
        :_destroy])
  end

  def flash_update(show_success)
    if show_success
      flash[:notice] = "#{@organization.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@organization.name}."
    end
  end
end
