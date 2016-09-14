# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j

  def do_post
    post :delete_documents, {
           :id                => service_request.id,
           :document_id       => doc.id,
           :format            => :js,
         }.with_indifferent_access
  end

  describe 'POST delete_documents' do

    let!(:protocol)         { create(:protocol_without_validations, primary_pi: jug2) }
    let!(:service_request)  { create(:service_request_without_validations, protocol: protocol) }
    let!(:provider)         { create(:provider, parent: create(:institution)) }
    let!(:program)          { create(:program, parent: provider) }
    let!(:core1)            { create(:core, parent: program) }
    let!(:core2)            { create(:core, parent: program) }
    let!(:ssr1)             { create(:sub_service_request, service_request: service_request, organization: core1)  }
    let!(:ssr2)             { create(:sub_service_request, service_request: service_request, organization: core2) }
    let!(:doc)              { create(:document, protocol: protocol) }

    before(:each) do
      doc.sub_service_requests << ssr1
      doc.sub_service_requests << ssr2
    end

    it 'should set tr_id' do
      do_post
      expect(assigns(:tr_id)).to eq "#document_id_#{doc.id}"
    end

    context 'no SubServiceRequest provided' do

      it 'should destroy the Document' do
        do_post
        expect {
          doc.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'SubServiceRequest provided' do

      before(:each) { session[:sub_service_request_id] = ssr1.id }

      context 'Document belongs to more than one SubServiceRequest' do

        it 'should destroy only the document for that SubServiceRequest' do
          do_post
          doc.reload
          expect(doc.destroyed?).to eq false
          expect(doc.sub_service_requests.size).to eq 1
        end
      end

      context 'Document belongs to one SubServiceRequest' do

        before(:each) do
          ssr2.documents.delete doc
          ssr2.save
        end

        it "should destroy the Document" do
          do_post
          expect {
            doc.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
