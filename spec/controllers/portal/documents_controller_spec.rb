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

require 'spec_helper'

describe Portal::DocumentsController do
  describe 'GET download' do
    # TODO: looks like this method is no longer used
  end

  describe 'POST override' do
    # TODO: looks like this method is no longer used (it uses alfresco)
  end

  describe 'POST upload' do
    # TODO: looks like this method is no longer used (it uses alfresco)
  end

  describe 'POST destroy' do
    # TODO: looks like this method is no longer used
  end

  # include EntityHelpers
  #
  # render_views
  #
  # before(:each) do
  #   @doc = stub_model Document, :title => 'document.xml', :content_type => 'xml'
  # end
  #
  # describe "GET documents/:object_id/download" do
  #
  #   it "should download a document given an id" do
  #     Document.should_receive(:find).and_return(@doc)
  #     @doc.should_receive(:url).and_return("spec/fixtures/document.xml")
  #     get "download", :object_id => @doc.id
  #   end
  #
  # end
  #
  # describe "POST documents/override" do
  #   it "should ovveride an already existing file" # do
  #   #
  #   #       test_document = stub_model ActionDispatch::Http::UploadedFile, :filename => 'document.xml', :type => 'xml', :tempfile => File.new("#{Rails.root}/spec/fixtures/document.xml")
  #   #
  #   #       Document.should_receive(:ticket).and_return('abc123')
  #   #       puts @doc.inspect
  #   #       get "override", :document => test_document, :document_id => @doc.id
  #   #     end
  #
  #   # Fuck it I'm not dealing with this
  #   # See http://stackoverflow.com/questions/7957823/rspec-converting-post-params-to-string-testing-file-uploader
  # end
  #
  # describe "POST documents/upload" do
  #   it "should upload a document"
  # end
  #
  # describe "DELETE documents/:id" do
  #   it "should delete a document" do
  #     Document.should_receive(:find).and_return(@doc)
  #     @doc.should_receive(:destroy)
  #     delete "destroy", :id => @doc.id
  #   end
  # end

end
