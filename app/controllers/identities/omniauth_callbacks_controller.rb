# Copyright © 2011-2022 MUSC Foundation for Research Development
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

class Identities::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def shibboleth
    @identity = Identity.find_for_shibboleth_oauth(request.env["omniauth.auth"], current_identity)

    if @identity.persisted?
      store_location_for(@identity, catalog_service_request_path(srid: params[:srid])) if params[:srid]
      sign_in_and_redirect(@identity, event: :authentication) #this will throw if @identity is not activated
      set_flash_message(:notice, :success, kind: "Shibboleth") if is_navigational_format?
    else
      session["devise.shibboleth_data"] = request.env["omniauth.auth"]
      redirect_to new_identity_registration_url(srid: params[:srid])
    end
  end

  def cas
    @identity = Identity.find_for_cas_oauth(request.env['omniauth.auth'], current_identity)

    if @identity.persisted?
      store_location_for(@identity, catalog_service_request_path(srid: params[:srid])) if params[:srid]
      sign_in_and_redirect(@identity, event: :authentication) #this will throw if @identity is not activated
      set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
    else
      session["devise.cas_data"] = request.env["omniauth.auth"]
      redirect_to new_identity_registration_url(srid: params[:srid])
    end
  end
end
