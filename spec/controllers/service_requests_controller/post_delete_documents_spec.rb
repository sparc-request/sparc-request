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
