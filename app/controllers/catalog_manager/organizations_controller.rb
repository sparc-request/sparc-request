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
    update_organization
    save_pricing_setups
    set_org_tags
    @organization.setup_available_statuses
    @entity = @organization
    render 'catalog_manager/organizations/update'
  end

  private

  def update_organization
    @attributes.delete(:id)
    if @organization.update_attributes(@attributes)
      @organization.update_descendants_availability(@attributes[:is_available])
      flash[:notice] = "#{@organization.name} saved correctly."
    else
      flash[:alert] = "Failed to update #{@organization.name}."
    end
  end

  def save_pricing_setups
    if params[:pricing_setups] && ['Program', 'Provider'].include?(@organization.type)
      params[:pricing_setups].each do |ps|
        if ps[1]['id'].blank?
          ps[1].delete(:id)
          ps[1].delete(:newly_created)
          @organization.pricing_setups.build(ps[1])
        else
          # @organization.pricing_setups.find(ps[1]['id']).update_attributes(ps[1])
          ps_id = ps[1]['id']
          ps[1].delete(:id)
          @organization.pricing_setups.find(ps_id).update_attributes(ps[1])
        end
        @organization.save
      end
    end
  end

  def set_org_tags
    unless @attributes[:tag_list] || @organization.type == 'Institution'
      @attributes[:tag_list] = ""
    end
  end
end
