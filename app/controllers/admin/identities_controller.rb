# Copyright © 2011-2020 MUSC Foundation for Research Development
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

class Admin::IdentitiesController < Admin::ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json {
        @identities =      Identity.sparc_users.search_query(params[:search])
        @total = @identities.count
        @identities = @identities.sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset] || 0)
      }
    end
  end

  def edit
    @identity = Identity.find(params[:id])
    @identity.populate_for_edit
  end

  def show
    @identity = Identity.find(params[:id])
    respond_to :js
  end

  def update
    @identity = Identity.find(params[:id])
    @identity.updater_id = current_user.id
    if @identity.update_attributes(identity_params)
      flash[:success] = t('admin.identities.updated')
    else
      @errors = @identity.errors
    end

    respond_to :js
  end

  protected
  
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
      :subspecialty,
      :gender,
      :gender_other,
      :age_group,
      :ethnicity,
      races_attributes: [:id, :name, :other_text, :new, :position, :_destroy]

    )
  end

end
