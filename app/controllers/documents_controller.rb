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

class DocumentsController < ApplicationController
  respond_to :html, :js, :json

  before_action :initialize_service_request
  before_action :authorize_identity
  before_action :find_document,             only: [:edit, :update, :destroy]
  before_action :find_protocol,             only: [:index, :new, :create, :update]

  def index
    @documents = @protocol.documents
  end

  def new
    @document     = @protocol.documents.new
    @header_text  = t(:documents)[:add][:header]
    @path         = documents_path(@document)
  end

  def create
    @document = @protocol.documents.create( document_params )

    if @document.valid?
      assign_organization_access

      flash.now[:success] = t(:documents)[:created]
    else
      @errors = @document.errors
    end

    render 'create', format: :js, type: :script
  end

  def edit
    @header_text  = t(:documents)[:edit][:header]
    @path         = document_path(@document)
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
end
