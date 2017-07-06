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

require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#create' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should assign @protocol' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      doc_params  = { doc_type: 'Neurology',  }


      post :create, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        document: doc_params
      }, xhr: true

      expect(assigns(:protocol)).to eq(protocol)
    end

    it 'should assign @document' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      doc_params  = { doc_type: 'Neurology', document: Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain') }


      post :create, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        document: doc_params
      }, xhr: true

      expect(assigns(:document).class).to eq(Document)
      expect(assigns(:document).protocol).to eq(protocol)
    end

    context 'document valid' do
      it 'should create document' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        doc_params  = { doc_type: 'Neurology', document: Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'text/plain') }



        post :create, params: {
          service_request_id: sr.id,
          protocol_id: protocol.id,
          document: doc_params
        }, xhr: true

        expect(Document.count).to eq(1)
      end

      it 'should set org access' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        org         = create(:organization)
        ssr         = create(:sub_service_request_without_validations, organization: org, service_request: sr, protocol_id: protocol.id)
        doc_params  = { doc_type: 'Neurology', document: Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'text/plain') }


        post :create, params: {
          service_request_id: sr.id,
          protocol_id: protocol.id,
          org_ids: [org.id],
          document: doc_params
        }, xhr: true

        expect(assigns(:document).sub_service_requests.include?(ssr)).to eq(true)
      end
    end

    context 'document invalid' do
      it 'should not create document' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        doc_params  = { doc_type: '' }


        post :create, params: {
          service_request_id: sr.id,
          protocol_id: protocol.id,
          document: doc_params
        }, xhr: true

        expect(Document.count).to eq(0)
      end

      it 'should assign @errors' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        doc_params  = { doc_type: '' }


        post :create, params: {
          service_request_id: sr.id,
          protocol_id: protocol.id,
          document: doc_params
        }, xhr: true

        expect(assigns(:errors)).to be
      end
    end

    it 'should render template' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      doc_params  = { doc_type: 'Neurology', document: Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain') }


      post :create, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        document: doc_params
      }, xhr: true

      expect(controller).to render_template(:create)
    end

    it 'should respond ok' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      doc_params  = { doc_type: 'Neurology', document: Rack::Test::UploadedFile.new(File.join('doc', 'musc_installation_example.txt'),'txt/plain') }


      post :create, params: {
        service_request_id: sr.id,
        protocol_id: protocol.id,
        document: doc_params
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
