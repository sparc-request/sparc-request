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

  def index
    sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @documents = sub_service_request.documents
  end

  def new
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @document = Document.new(service_request_id: @sub_service_request.service_request_id)
    @header_text = "New Document"
  end

  def create
    @sub_service_request = SubServiceRequest.find(params[:document][:sub_service_request_id])
    @document = Document.new(params[:document])
    if @document.valid?
      @document.save
      @sub_service_request.documents << @document
      @sub_service_request.save
      flash.now[:success] = "Document Uploaded!"
    else
      @errors = @document.errors
    end
  end

  def edit
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @document = Document.find(params[:id])
    @header_text = "Edit Document"
  end

  def update
    @document = Document.find(params[:id])
    if @document.update_attributes(params[:document])
      flash.now[:success] = "Document Updated!"
    else
      @errors = @document.errors
    end
  end

  def destroy
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    @document = Document.find(params[:id])
    @sub_service_request.documents.delete @document
    @sub_service_request.save
    @document.destroy if @document.sub_service_requests.empty?
    flash.now[:success] = "Document Destroyed!"
  end
end
