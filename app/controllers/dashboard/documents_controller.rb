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
    @permission_to_edit = current_user.can_edit_protocol?(@protocol)
    permission_to_view  = current_user.can_view_protocol?(@protocol)
    @admin_orgs         = current_user.authorized_admin_organizations

    respond_to :json
  end

  def new
    controller          = ::DocumentsController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.new
    @document = controller.instance_variable_get(:@document)

    respond_to :js
  end

  def create
    controller          = ::DocumentsController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.instance_variable_set(:@document, @document)
    controller.create
    @document = controller.instance_variable_get(:@document)
    @errors = controller.instance_variable_get(:@errors)

    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    controller          = ::DocumentsController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.instance_variable_set(:@document, @document)
    controller.update
    @document = controller.instance_variable_get(:@document)
    @errors   = controller.instance_variable_get(:@errors)

    respond_to :js
  end

  def destroy
    controller          = ::DocumentsController.new
    controller.request  = request
    controller.response = response
    controller.destroy

    respond_to :js
  end

  private

  def document_params
    params.require(:document).permit(
      :document,
      :doc_type,
      :doc_type_other,
      :sub_service_requests,
      :protocol_id
    )
  end

  def find_document
    @document = Document.find(params[:id])
  end

  def find_protocol
    if @document
      @protocol = @document.protocol
    elsif params[:protocol_id]
      @protocol = Protocol.find(params[:protocol_id])
    else
      @protocol = Protocol.find(document_params[:protocol_id])
    end
  end

  def authorize_admin_access_document
    @admin_orgs = current_user.authorized_admin_organizations

    unless current_user.catalog_overlord? || @authorization.can_edit? || (@admin_orgs & @document.all_organizations).any?
      authorization_error('You are not allowed to edit this document.')
    end
  end
end
