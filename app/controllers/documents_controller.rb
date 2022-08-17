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

require('zip')

class DocumentsController < ApplicationController
  before_action :initialize_service_request
  before_action :authorize_identity
  skip_before_action :verify_authenticity_token

  include DocumentsControllerShared

  def bulk_download

    if(params[:protocol_id] && params[:document_ids])
      @protocol_id = params[:protocol_id]
      @document_ids = params[:document_ids]

      @documents = Protocol.find(@protocol_id).documents.where(id: @document_ids) #filter the checked documents

      file_name = "bulk_download_#{@protocol_id}.zip"
      temp_file = Tempfile.new(file_name)

      respond_to do |format|
        format.zip do
          Zip::OutputStream.open(temp_file) { |zos| } #initialize the temp file as a zip file

          Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip| #add files to zip file
            @documents.each do |doc|
              doc_path = File.expand_path('../../../public' + doc.document.url, __FILE__)
              zip.add("#{doc.document_file_name}", doc_path)
            end
          end

          zip_data = File.read(temp_file.path) #read binary data from the temp file
          send_data(zip_data, type: 'application/zip', disposition: 'attachment', filename: file_name) #send the data to the browser as an attachment

          temp_file.close
          temp_file.unlink

        end
      end

    end
  end

  def bulk_edit

    @protocol = Protocol.find(params[:protocol_id])
    @documents = @protocol.documents.eager_load(:organizations)

    if params[:document_ids]
      @document_ids = params[:document_ids]
      @documents = @documents.where(id: @document_ids) #filter the checked documents
    end

    respond_to do |format|
      format.js
    end

  end

  def bulk_update

    protocol = Protocol.find(params[:protocol_id])
    document_ids = params[:document_ids]

    if document_ids
      document_ids.each do |id|
        doc = Document.find(id)
        doc.update_attributes(share_all: params[:share_all])
        doc.sub_service_requests = protocol.sub_service_requests.where(organization_id: params[:org_ids])
      end
    end

    respond_to do |format|
      format .js { render :update }
    end

  end

end
