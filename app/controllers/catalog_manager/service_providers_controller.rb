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

class CatalogManager::ServiceProvidersController < CatalogManager::AppController

  def create
    @service_provider = ServiceProvider.new(service_provider_params)
    @identity = Identity.find(@service_provider.identity_id)
    @organization = @service_provider.organization
    @user_rights  = user_rights(@organization.id)

    if @service_provider.save
      flash[:notice] = "Service Provider created successfully."
    else
      @service_provider.errors.messages.each do |field, message|
        flash[:alert] = "Error adding Service Provider: #{message.first}."
      end
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def destroy
    @service_provider = ServiceProvider.find_by(service_provider_params)
    @identity = Identity.find(@service_provider.identity_id)
    @organization = @service_provider.organization
    @user_rights  = user_rights(@organization.id)

    if @service_provider.destroy
      flash[:notice] = "Service Provider removed successfully."
    else
      flash[:alert] = "Error removing Service Provider."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def update
    @service_provider = ServiceProvider.find_by(identity_id: service_provider_params[:identity_id], organization_id: service_provider_params[:organization_id])
    @identity = Identity.find(@service_provider.identity_id)
    @organization = @service_provider.organization
    @user_rights  = user_rights(@organization.id)

    if @service_provider.update_attributes(service_provider_params)
      flash[:notice] = "Service Provider successfully updated."
    else
      flash[:alert] = "Error updating Service Provider."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  private

  def service_provider_params
    params.require(:service_provider).permit(
      :identity_id,
      :organization_id,
      :is_primary_contact,
      :hold_emails)
  end
end
