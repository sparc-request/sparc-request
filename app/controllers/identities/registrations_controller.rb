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

class Identities::RegistrationsController < Devise::RegistrationsController

  def edit
    session[:return_to] ||= request.referer
    @identity = current_user
    @back = request.referer 
  end

  def update
    @identity = current_user
    @professional_organization_id = params[:project_role][:identity_attributes][:professional_organization_id]
    attrs = fix_professional_organization_id if @professional_organization_id != @identity.professional_organization_id
    if @identity.update_attributes(attrs)
      redirect_to session.delete(:return_to)
      flash[:success] = t(:devise)[:profile][:updated]
    else
      render 'edit'
    end
  end

  private
  def identity_params
    params.require(:identity).permit(:orcid,
        :credentials,
        :credentials_other,
        :email,
        :era_commons_name,
        :professional_organization_id,
        :phone,
        :subspecialty)
  end

  def fix_professional_organization_id
    attrs = identity_params
    attrs = attrs.merge(professional_organization_id: @professional_organization_id)
    attrs
  end
end