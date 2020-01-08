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

class Identities::RegistrationsController < Devise::RegistrationsController
  def create
    respond_to :js

    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        flash[:notice] = t('devise.registrations.signed_up')
        sign_up(resource_name, resource)
        @path = after_sign_up_path_for(resource)
      else
        flash[:notice] = t("devise.registrations.signed_up_but_#{resource.inactive_message}")
        expire_data_after_sign_in!
        @path = after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      @errors = resource.errors
    end
  end

  def edit
    store_location_for(resource, request.referrer)
  end

  def update
    @identity = current_user
    if @identity.update_attributes(identity_params)
      flash[:success] = t(:devise)[:profile][:updated]
      @path = stored_location_for(resource) || root_path
    else
      @errors = @identity.errors
    end
  end

  private

  def sign_up_params
    attrs = devise_parameter_sanitizer.sanitize(:sign_up)
    attrs[:phone] = sanitize_phone(attrs[:phone])
    attrs
  end

  def identity_params
    params[:identity][:phone]                         = sanitize_phone(params[:identity][:phone])
    params[:identity][:professional_organization_id]  = params[:project_role].nil? ? nil :  params[:project_role][:identity_attributes][:professional_organization_id]

    params.require(:identity).permit(
      :first_name,
      :last_name,
      :orcid,
      :credentials,
      :credentials_other,
      :email,
      :era_commons_name,
      :professional_organization_id,
      :phone,
      :subspecialty
    )
  end
end
