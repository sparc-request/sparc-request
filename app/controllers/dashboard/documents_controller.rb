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

class Dashboard::DocumentsController < Dashboard::BaseController
  before_action :find_document,                   only: [:edit, :update, :destroy]
  before_action :find_protocol,                   only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :find_admin_for_protocol,         only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :protocol_authorizer_view,        only: [:index]
  before_action :protocol_authorizer_edit,        only: [:new, :create, :edit, :update, :destroy]

  before_action :authorize_admin_access_document, only: [:edit, :update, :destroy]

  def index
    @documents          = @protocol.documents
    @permission_to_edit = @user.can_edit_protocol?(@protocol)
    permission_to_view  = @user.can_view_protocol?(@protocol)
    @admin_orgs         = @user.authorized_admin_organizations
  end

  def new
    @document     = @protocol.documents.new
    @action       = 'new'
    @header_text  = t(:documents)[:add][:header]
  end

  def create
    @document = @protocol.documents.create(document_params)

    if @document.valid?
      assign_organization_access

      flash.now[:success] = t(:documents)[:created]
    else
      @errors = @document.errors
    end
  end

  def edit
    @action       = 'edit'
    @header_text  = t(:documents)[:edit][:header]
  end

  def update
    if @document.update_attributes(document_params)
      assign_organization_access

      flash.now[:success] = t(:documents)[:updated]
    else
      @errors = @document.errors
    end
  end

  def destroy
    DocumentRemover.new(params[:id])

    flash.now[:success] = t(:documents)[:destroyed]
  end

  private

  def document_params
    params.require(:document).permit(:document,
      :doc_type,
      :doc_type_other,
      :sub_service_requests,
      :protocol_id)
  end

  def find_document
    @document = Document.find(params[:id])
  end

  def find_protocol
    if @document
      @protocol = @document.protocol
    else
      @protocol = Protocol.find(params[:protocol_id])
    end
  end

  def assign_organization_access
    @document.sub_service_requests = @protocol.sub_service_requests.where(organization_id: params[:org_ids])
  end

  def authorize_admin_access_document
    if @user.catalog_overlord?
      true
    else
      @admin_orgs = @user.authorized_admin_organizations

      unless @authorization.can_edit? || (@admin_orgs & @document.all_organizations).any?
        render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to edit this document.' }
      end
    end
  end
end
