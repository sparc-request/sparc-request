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

class CatalogManager::CatalogController < CatalogManager::AppController
  respond_to :js, :haml, :json

  def index
    @institutions = Institution.order(Arel.sql('`order`,`name`'))
    @show_available_only = params[:show_available_only] ? params[:show_available_only] == "true" : true

    @editable_organizations = current_user.catalog_manager_organizations

    respond_to do |format|
      format.html
      format.js
    end
  end

  def load_program_accordion
    @editable_organizations = current_user.catalog_manager_organizations
    @program = Organization.find(params[:program_id])
    @program_editable = @editable_organizations.include?(@program)
    @availability = params[:show_available_only] ? params[:show_available_only] == "true" : true, true
  end

  def load_core_accordion
    @core = Organization.find(params[:core_id])
    @core_editable = current_user.catalog_manager_organizations.include?(@core)
    @availability = params[:show_available_only] ? params[:show_available_only] == "true" : true, true
  end
end
