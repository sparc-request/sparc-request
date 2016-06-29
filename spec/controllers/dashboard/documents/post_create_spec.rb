require 'rails_helper'

RSpec.describe Dashboard::DocumentsController do

  describe 'POST #create' do

    let(:logged_in_user) { create(:identity) }

    before :each do
      log_in_dashboard_identity(obj: logged_in_user)
    end

    context 'user is authorized to edit protocol' do
      before :each do
        @protocol = create(:protocol_without_validations, primary_pi: logged_in_user)
      end

      context 'instance variables' do
        before :each do
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
          @ssr            = create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                            create(:super_user, identity: logged_in_user, organization: organization)
          document        = Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain')
          params          = { org_ids: [organization.id], protocol_id: @protocol.id, document: { protocol: @protocol, doc_type: 'Protocol', document: document } }

          xhr :post, :create, params, format: :js
        end

        it 'should assign @protocol from params[:protocol_id]' do
          expect(assigns(:protocol)).to eq(@protocol)
        end

        it 'should assign @admin' do
          expect(assigns(:admin)).to eq(true)
        end

        it 'should assign @authorization' do
          expect(assigns(:authorization)).to be
        end

        it 'should create Document' do
          expect(@protocol.documents.count).to eq(1)
        end

        it { is_expected.to render_template 'dashboard/documents/create' }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:document] describes a valid Document' do
        before :each do
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
          @ssr            = create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft')
                            create(:super_user, identity: logged_in_user, organization: organization)
          @document       = Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain')
          params          = { org_ids: [organization.id], protocol_id: @protocol.id, document: { protocol: @protocol, doc_type: 'Protocol', document: @document } }
          
          xhr :post, :create, params, format: :js
        end 

        it 'should assign sub_service_requests to the document' do
          expect(assigns(:document).reload.sub_service_requests).to eq([@ssr])
        end

        it 'should not set @errors' do
          expect(assigns(:errors)).to be_nil
        end

        it { is_expected.to render_template 'dashboard/documents/create' }
        it { is_expected.to respond_with :ok }
      end

      context 'params[:document] describes an invalid Document' do
        before :each do
          document  = Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain')
          params    = { protocol_id: @protocol.id, document: { protocol: @protocol, doc_type: nil, document: document } }

          xhr :post, :create, params, format: :js
        end

        it 'should set @errors' do
          expect(assigns(:errors)).to be
        end

        it { is_expected.to render_template 'dashboard/documents/create' }
        it { is_expected.to respond_with :ok }
      end
    end

    context 'user is not authorized to edit protocol' do
      before :each do
        protocol  = create(:protocol_without_validations, primary_pi: create(:identity))
        params    = { protocol_id: protocol.id, document: {} }

        xhr :post, :create, params, format: :js
      end

      it { is_expected.to render_template 'dashboard/shared/_authorization_error' }
      it { is_expected.to respond_with :ok }
    end
  end
end
