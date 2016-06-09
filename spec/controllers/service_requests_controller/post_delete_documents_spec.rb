require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request

  def do_post
    post :delete_documents, {
           :id                => service_request.id,
           :document_id       => doc.id,
           :format            => :js,
         }.with_indifferent_access
  end

  describe 'POST delete_documents' do

    let!(:doc)   { Document.create(service_request_id: service_request.id) }
    let!(:ssr1)  { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id)  }
    let!(:ssr2)  { create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }

    let!(:core2) { create(:core, parent_id: program.id) }

    before(:each) do
      doc.update_attribute(:id, 1)
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
