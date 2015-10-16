require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  let!(:core2) { create(:core, parent_id: program.id) }
  let!(:core3) { create(:core, parent_id: program.id) }

  describe 'POST document_management navigate' do
    let!(:doc)  { Document.create(service_request_id: service_request.id) }
    let!(:ssr1) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id)  }
    let!(:ssr2) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }
    let!(:ssr3) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core3.id) }

    before(:each) do
      @request.env['HTTP_REFERER'] = "/service_requests/#{service_request.id}/document_management"
      controller.instance_variable_set(:@validation_groups, {review_view: ['document_management']})
      doc.sub_service_requests << ssr1
      doc.sub_service_requests << ssr2
      doc.reload
    end

    context 'params[:upload_clicked] == "1"' do

      context 'params[:document] and params[:document_id] absent' do

        let(:params) do
          { :location                     => 'document_management',
            :current_location             => 'document_management',
            process_ssr_organization_ids: [ssr2.organization_id.to_s, ssr3.organization_id.to_s],
            :doc_type                     => 'budget',
            :upload_clicked               => '1',
            :action                       => 'document_management',
            :controller                   => 'service_requests',
            :id                           => service_request.id
          }
        end

        before(:each) { do_post params }

        it 'should set @service_list of ServiceRequest' do
          expect(assigns(:service_list)).to eq service_request.service_list.with_indifferent_access
        end

        it 'should set session[:errors]' do
          expect(session[:errors]).to eq({:document=>["You must select a document to upload"]})
        end
      end

      context 'params[:process_ssr_organization_ids] absent' do

        let(:params) do
          { :location                     => 'document_management',
            :current_location             => 'document_management',
            :document_id                  => doc.id.to_s,
            :doc_type                     => 'budget',
            :upload_clicked               => '1',
            :action                       => 'document_management',
            :controller                   => 'service_requests',
            :id                           => service_request.id
          }
        end
        before(:each) { do_post params }

        it 'should set @service_list of ServiceRequest' do
          expect(assigns(:service_list)).to eq service_request.service_list.with_indifferent_access
        end

        it 'should set session[:errors]' do
          expect(session[:errors]).to eq({:recipients=>["You must select at least one recipient"]})
        end
      end

      context 'params[:doc_type] == "" and params[:process_ssr_organization_ids] absent' do

        let(:params) do
          { :location                     => 'document_management',
            :current_location             => 'document_management',
            :document_id                  => doc.id.to_s,
            :doc_type                     => '',
            :upload_clicked               => '1',
            :action                       => 'document_management',
            :controller                   => 'service_requests',
            :id                           => service_request.id
          }
        end

        before(:each) { do_post params }

        it 'should set @service_list of ServiceRequest' do
          expect(assigns(:service_list)).to eq service_request.service_list.with_indifferent_access
        end

        it 'should set session[:errors]' do
          expect(session[:errors]).to include({:recipients=>["You must select at least one recipient"]})
        end
      end
    end

    context 'params[:doc_type], params[:process_ssr_organization_ids], ' do

      context 'params[:document_id] present' do

        context 'params[:process_ssr_organization_ids] nonempty' do

          context 'SubServiceRequest in session' do

            before(:each) { session[:sub_service_request_id] = ssr1.id }

            context 'Document belongs to multiple SubServiceRequests' do

              let(:params) do
                { :location                     => 'document_management',
                  :current_location             => 'document_management',
                  :document_id                  => doc.id.to_s,
                  process_ssr_organization_ids: [ssr2.organization_id.to_s, ssr3.organization_id.to_s],
                  :doc_type                     => 'budget',
                  :upload_clicked               => '1',
                  :action                       => 'document_management',
                  :controller                   => 'service_requests',
                  :id                           => service_request.id
                }
              end

              it 'should create another Document with the updates' do

                document_count = Document.count

                expect do
                  do_post params
                  doc.reload
                end.not_to change { doc }

                expect(Document.count).to eq(document_count + 1)
                new_doc = Document.all.sort { |x,y|  x.created_at <=> y.created_at }.last
                expect(new_doc.doc_type).to eq('budget')
              end

              it 'should add/remove SubServiceRequests from Document' do
                expect(doc.sub_service_requests.size).to eq(2)
                do_post params
                doc.reload

                expect(doc.sub_service_requests).to eq([ssr2, ssr3])
              end
            end

            context 'Document belongs to one SubServiceRequest' do

              let(:params) do
                { :location                     => 'document_management',
                  :current_location             => 'document_management',
                  :document_id                  => doc.id.to_s,
                  process_ssr_organization_ids: [ssr2.organization_id.to_s],
                  :doc_type                     => 'budget',
                  :upload_clicked               => '1',
                  :action                       => 'document_management',
                  :controller                   => 'service_requests',
                  :id                           => service_request.id
                }
              end

              before(:each) { doc.sub_service_requests.delete ssr2 }

              it 'should not create new Documents' do
                doc_count = Document.count
                do_post params
                expect(Document.count).to eq(doc_count)
              end

              it 'should update an existing Document' do
                do_post params
                doc.reload
                expect(doc.sub_service_requests).to eq([ssr2])
                expect(doc.doc_type).to eq('budget')
              end
            end
          end

          context 'no SubServiceRequest in session' do

            let(:params) do
              { :location                     => 'document_management',
                :current_location             => 'document_management',
                :document_id                  => doc.id.to_s,
                process_ssr_organization_ids: [ssr2.organization_id.to_s, ssr3.organization_id.to_s],
                :doc_type                     => 'budget',
                :upload_clicked               => '1',
                :action                       => 'document_management',
                :controller                   => 'service_requests',
                :id                           => service_request.id
              }
            end

            it 'should not create new Documents' do
              doc_count = Document.count
              do_post params
              expect(Document.count).to eq(doc_count)
            end

            it 'should update an existing Document' do
              expect(doc.sub_service_requests.size).to eq(2)
              do_post params
              doc.reload
              # access to Document removed from ssr1, added to ssr3, and doc_type changed to budget
              expect(doc.sub_service_requests).to eq([ssr2, ssr3])
              expect(doc.doc_type).to eq('budget')
            end
          end
        end


        context 'params[:process_ssr_organization_ids] empty' do

          it 'should destroy Document' do
            expect(doc.sub_service_requests.size).to eq(2)
            post :navigate, {
                   :location                     => 'document_management',
                   :current_location             => 'document_management',
                   :document_id                  => doc.id.to_s,
                   process_ssr_organization_ids: [],
                   :doc_type                     => 'budget',
                   :upload_clicked               => '1',
                   :action                       => 'document_management',
                   :controller                   => 'service_requests',
                   :id                           => service_request.id
                 }.with_indifferent_access

            expect { doc.reload }.to raise_error(ActiveRecord::RecordNotFound)
            expect(service_request.documents.size).to eq 0
          end
        end
      end

      context 'params[:document] present' do

        it 'should create a new Document' do
          expect(service_request.documents.size).to eq(1)
          post :navigate, {
                 :location                     => 'document_management',
                 :current_location             => 'document_management',
                 process_ssr_organization_ids: [ssr1.organization_id.to_s, ssr2.organization_id.to_s],
                 :doc_type                     => 'budget',
                 :document                     => file_for_upload,
                 :action                       => 'document_management',
                 :controller                   => 'service_requests',
                 :id                           => service_request.id
               }.with_indifferent_access
          expect(ssr1.reload.documents.size).to eq(2)
          expect(ssr2.reload.documents.size).to eq(2)
        end
      end
    end
  end

  def do_post(params)
    post :navigate, params.with_indifferent_access
  end
end
