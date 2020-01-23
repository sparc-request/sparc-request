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

module DocumentsControllerShared
  extend ActiveSupport::Concern

  included do
    before_action :find_document, only: [:edit, :update, :destroy]
    before_action :find_protocol
  end

  def index
    respond_to :json

    @documents = @protocol.documents.eager_load(:organizations)
  end

  def new
    respond_to :js

    @document = @protocol.documents.new
  end

  def create
    respond_to :js

    @document = Document.new(document_params)

    if @document.save
      assign_organization_access

      flash.now[:success] = t(:documents)[:created]
    else
      @errors = @document.errors
    end
  end

  def edit
    respond_to :js
  end

  def update
    respond_to :js

    if @document.update_attributes(document_params)
      assign_organization_access

      flash.now[:success] = t(:documents)[:updated]
    else
      @errors = @document.errors
    end
  end

  def destroy
    respond_to :js

    DocumentRemover.new(@document)
    flash.now[:success] = t(:documents)[:destroyed]
  end

  protected

  def find_document
    @document = Document.find(params[:id])
  end

  def find_protocol
    @protocol =
      if @document
        @document.protocol
      elsif @service_request
        @service_request.protocol
      else
        Protocol.find(params[:protocol_id] || document_params[:protocol_id])
      end
  end

  def assign_organization_access
    @document.sub_service_requests = @protocol.sub_service_requests.where(organization_id: params[:org_ids])
  end

  def document_params
    params.require(:document).permit(
      :document,
      :doc_type,
      :doc_type_other,
      :sub_service_requests,
      :protocol_id
    )
  end
end
