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

RSpec.describe NotesController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#create' do
    it 'should assign @notable_id' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params
      }, xhr: true

      expect(assigns(:notable_id)).to eq(sr.id.to_s)
    end

    it 'should assign @notable_type' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params
      }, xhr: true

      expect(assigns(:notable_type)).to eq('ServiceRequest')
    end

    it 'should assign @notable' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params
      }, xhr: true

      expect(assigns(:notable)).to eq(sr)
    end

    it 'should assign @in_dashboard' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params,
        in_dashboard: 'true'
      }, xhr: true

      expect(assigns(:in_dashboard)).to eq(true)
    end

    context 'note valid' do
      it 'should create note' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        note_params = { notable_id: sr.id, notable_type: 'ServiceRequest', body: 'asdf' }

        session[:identity_id] = logged_in_user.id

        post :create, params: {
          service_request_id: sr.id,
          note: note_params
        }, xhr: true

        expect(Note.count).to eq(1)
      end
    end

    context 'note invalid' do
      it 'should not create note' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        note_params = { notable_id: sr.id, notable_type: 'ServiceRequest', body: '' }

        session[:identity_id] = logged_in_user.id

        post :create, params: {
          service_request_id: sr.id,
          note: note_params
        }, xhr: true

        expect(Note.count).to eq(0)
      end

      it 'should assign @errors' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        note_params = { notable_id: sr.id, notable_type: 'ServiceRequest', body: '' }

        session[:identity_id] = logged_in_user.id

        post :create, params: {
          service_request_id: sr.id,
          note: note_params
        }, xhr: true

        expect(assigns(:errors)).to be
      end
    end

    it 'should render template' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params
      }, xhr: true

      expect(controller).to render_template(:create)
    end

    it 'should respond ok' do
      protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr          = create(:service_request_without_validations, protocol: protocol)
      note_params = { notable_id: sr.id, notable_type: 'ServiceRequest' }

      session[:identity_id] = logged_in_user.id

      post :create, params: {
        service_request_id: sr.id,
        note: note_params
      }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
