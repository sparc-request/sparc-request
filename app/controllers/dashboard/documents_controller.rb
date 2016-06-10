# Copyright © 2011 MUSC Foundation for Research Development
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

class Dashboard::DocumentsController < Dashboard::BaseController
  before_filter :find_protocol,             only: [:index, :new, :create, :edit, :update, :destroy]
  before_filter :find_admin_for_protocol,   only: [:index, :new, :create, :edit, :update, :destroy]
  before_filter :protocol_authorizer_edit,  only: [:new, :create, :edit, :update, :destroy]

  def index
    @permission_to_edit = @protocol.project_roles.where(identity: @user, project_rights: ['approve', 'request']).any?
    @documents          = @protocol.documents
    
    if !@permission_to_edit
      admin_orgs = @user.authorized_admin_organizations
      @documents = @documents.reject { |document| (admin_orgs & document.sub_service_requests.map(&:org_tree).flatten.uniq).empty? }
    end
  end

  def new
    @document     = @protocol.documents.new
    @header_text  = t(:dashboard)[:documents][:add]
  end

  def create
    @document = Document.create(params[:document])

    if @document.valid?
      assign_organization_access

      flash.now[:success] = t(:dashboard)[:documents][:created]
    else
      @errors = @document.errors
    end
  end

  def edit
    @document     = Document.find(params[:id])
    @header_text  = t(:dashboard)[:documents][:edit]
  end

  def update
    @document = Document.find(params[:id])

    if @document.update_attributes(params[:document])
      assign_organization_access

      flash.now[:success] = t(:dashboard)[:documents][:updated]
    else
      @errors = @document.errors
    end
  end

  def destroy
    Dashboard::DocumentRemover.new(params[:id])
    
    flash.now[:success] = t(:dashboard)[:documents][:destroyed]
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:protocol_id])
  end

  def assign_organization_access
    @document.sub_service_requests = @protocol.sub_service_requests.where(organization_id: params[:org_ids])
  end
end
