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

class CatalogManager::CatalogManagersController < CatalogManager::AppController

  def create
    @catalog_manager = CatalogManager.new(catalog_manager_params)
    @identity = @catalog_manager.identity
    @organization = @catalog_manager.organization
    @user_rights  = user_rights(@organization.id)

    if @catalog_manager.save
      flash[:notice] = "Catalog Manager created successfully."
    else
      @catalog_manager.errors.messages.each do |field, message|
        flash[:alert] = "Error adding Catalog Manager: #{message.first}."
      end
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def destroy
    @catalog_manager = CatalogManager.find_by(catalog_manager_params)
    @identity = @catalog_manager.identity
    @organization = @catalog_manager.organization
    @user_rights  = user_rights(@organization.id)

    if @catalog_manager.destroy
      flash[:notice] = "Catalog Manager removed successfully."
    else
      flash[:alert] = "Error removing Catalog Manager."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def update
    @catalog_manager = CatalogManager.find_by(identity_id: catalog_manager_params[:identity_id], organization_id: catalog_manager_params[:organization_id])
    @identity = @catalog_manager.identity
    @organization = @catalog_manager.organization
    @user_rights  = user_rights(@organization.id)

    if @catalog_manager.update_attributes(catalog_manager_params)
      flash[:notice] = "Catalog Manager successfully updated."
    else
      flash[:alert] = "Error updating Catalog Manager."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  private

  def catalog_manager_params
    params.require(:catalog_manager).permit(
      :identity_id,
      :organization_id,
      :edit_historic_data)
  end
end
