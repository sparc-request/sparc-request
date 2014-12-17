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

describe Portal::SubServiceRequestsController do
  stub_portal_controller

  let!(:identity)        { FactoryGirl.create(:identity) }
  let!(:institution)     { FactoryGirl.create(:institution) }
  let!(:provider)        { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program)         { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core)            { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core2)            { FactoryGirl.create(:core, parent_id: program.id) }

  before :each do
    @study = Protocol.new(FactoryGirl.attributes_for(:protocol))
    @study.save(:validate => false)
    @service_request = ServiceRequest.new(FactoryGirl.attributes_for(:service_request, :protocol_id => @study.id))
    @service_request.save(:validate => false)
    @ssr = FactoryGirl.create(:sub_service_request, service_request_id: @service_request.id, organization_id: core.id)
  end

  describe 'methods' do

    describe 'show' do

      it 'should set sub_service_request' do
        session[:identity_id] = identity.id
        get :show, {
          format: :js,
          id: @ssr.id,
        }.with_indifferent_access

        assigns(:sub_service_request).should eq @ssr
      end
    end

    describe 'add_line_item' do

      let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }

      before(:each) do
        request.env["HTTP_ACCEPT"] = "application/javascript" 
      end

      it 'should work (smoke test)' do
        post(
            :add_line_item,
            :id              => @ssr.id,
            :new_service_id  => service.id)

        @service_request.reload
        @service_request.arms.count.should eq 1
        @service_request.line_items.count.should eq 1
        @service_request.line_items[0].quantity.should eq nil
        @service_request.line_items[0].line_items_visits.count.should eq 1
      end

      it 'should create a new visit grouping for each arm' do
        @service_request.protocol.create_arm(visit_count: 5)
        @service_request.protocol.create_arm(visit_count: 5)

        post(
            :add_line_item,
            :id              => @ssr.id,
            :new_service_id  => service.id)

        @service_request.reload
        line_items = @service_request.line_items
        arms = @service_request.arms

        line_items.count.should eq 1
        line_items[0].quantity.should eq nil
        line_items[0].line_items_visits.count.should eq 2
        line_items[0].line_items_visits[0].should eq arms[0].line_items_visits[0]
        line_items[0].line_items_visits[1].should eq arms[1].line_items_visits[0]
        line_items[0].line_items_visits[1].visits.count.should eq 5
        arms[0].line_items_visits.count.should eq 1
        arms[0].line_items_visits[0].visits.count.should eq 5
        arms[1].line_items_visits.count.should eq 1
        arms[1].line_items_visits[0].visits.count.should eq 5
      end
    end

    describe 'documents' do
      let!(:doc)  { Document.create(service_request_id: @service_request.id, doc_type: 'protocol') }
      let!(:ssr2) { FactoryGirl.create(:sub_service_request, service_request_id: @service_request.id, organization_id: core2.id) }

      before(:each) do
        @request.env['HTTP_REFERER'] = "/service_requests/#{@service_request.id}/document_management"
        doc.sub_service_requests << @ssr
      end

      it 'should create a new document' do
        tempDoc = fake_document_upload
        @ssr.documents.size.should eq(1)
        post :new_document, {
          :process_ssr_organization_ids => [@ssr.organization_id.to_s],
          :doc_type                     => 'budget',
          :document                     => tempDoc,
          :id                           => @ssr.id
        }.with_indifferent_access
        @ssr.reload
        @ssr.documents.size.should eq(2)
      end

      it 'should update an existing document' do
        doc.doc_type.should eq('protocol')
        post :new_document, {
          :document_id                  => doc.id,
          :doc_type                     => 'hipaa',
          :process_ssr_organization_ids => [@ssr.organization_id.to_s],
          :is_edit                      => 'true',
          :id                           => @ssr.id
        }.with_indifferent_access
        doc.reload
        doc.doc_type.should eq('hipaa')
      end
    end
  end
end

