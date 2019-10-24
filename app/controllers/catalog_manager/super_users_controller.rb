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

class CatalogManager::SuperUsersController < CatalogManager::AppController

  def create
    @super_user = SuperUser.new(super_user_params)
    @identity = Identity.find(@super_user.identity_id)
    @organization = @super_user.organization
    @user_rights  = user_rights(@organization.id)

    if @super_user.save
      flash[:notice] = "Super User created successfully."
    else
      @super_user.errors.messages.each do |field, message|
        flash[:alert] = "Error adding Super User: #{message.first}."
      end
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def destroy
    @super_user = SuperUser.find_by(super_user_params)
    @identity = Identity.find(@super_user.identity_id)
    @organization = @super_user.organization
    @user_rights  = user_rights(@organization.id)

    if @super_user.destroy
      flash[:notice] = "Super User removed successfully."
    else
      flash[:alert] = "Error removing Super User."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  def update
    @super_user = SuperUser.find_by(identity_id: super_user_params[:identity_id], organization_id: super_user_params[:organization_id])
    @identity = @super_user.identity
    @organization = @super_user.organization
    @user_rights  = user_rights(@organization.id)

    if @super_user.update_attributes(super_user_params)
      flash[:notice] = "Super User successfully updated."
    else
      flash[:alert] = "Error updating Super Userr."
    end

    render 'catalog_manager/organizations/refresh_user_rights_row'
  end

  private

  def super_user_params
    params.require(:super_user).permit(
      :identity_id,
      :organization_id,
      :access_empty_protocols,
      :billing_manager)
  end
end
