# Copyright © 2011-2016 MUSC Foundation for Research Development
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

# index new create edit update delete show

RSpec.describe ProjectsController do
  let!(:service_request) { FactoryGirl.create(:service_request_without_validations) }
  let!(:identity) { create(:identity) }

  stub_controller

  context 'do not have a project' do
    describe 'GET new' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { id: nil, format: :js }.with_indifferent_access
        expect(assigns(:service_request)).to eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :new, { id: nil, format: :js }.with_indifferent_access
        expect(assigns(:protocol).class).to eq Project
        expect(assigns(:protocol).requester_id).to eq identity.id
      end
    end

    describe 'GET create' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        xhr :get, :create, { id: nil, format: :js }.with_indifferent_access
        expect(assigns(:service_request)).to eq service_request
      end

      it 'should create a project with the given parameters' do
        session[:service_request_id] = service_request.id
        xhr :get, :create, { id: nil, format: :js, project: { title: 'this is the title', funding_status: 'not in a million years' } }.with_indifferent_access
        expect(assigns(:protocol).title).to eq 'this is the title'
        expect(assigns(:protocol).funding_status).to eq 'not in a million years'
      end

      it 'should put the project id into the session' do
        session[:service_request_id] = service_request.id
        xhr :get, :create, { id: nil, format: :js }.with_indifferent_access
        expect(session[:saved_protocol_id]).to eq assigns(:protocol).id
      end
    end
  end

  context 'already have a project' do
    let!(:project) {
      project = Project.create(attributes_for(:protocol))
      project.save!(validate: false)
      project_role = create(
          :project_role,
          protocol_id: project.id,
          identity_id: identity.id,
          project_rights: "approve",
          role: "pi")
      project.reload
      project
    }

    describe 'GET edit' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { id: project.id, format: :js }.with_indifferent_access
        expect(assigns(:service_request)).to eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        get :edit, { id: project.id, format: :js }.with_indifferent_access
        expect(assigns(:protocol).class).to eq Project
      end
    end

    describe 'GET update' do
      it 'should set service_request' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        xhr :get, :update, { id: project.id, format: :js }.with_indifferent_access
        expect(assigns(:service_request)).to eq service_request
      end

      it 'should set project' do
        session[:service_request_id] = service_request.id
        session[:identity_id] = identity.id
        xhr :get, :update, { id: project.id, format: :js }.with_indifferent_access
        expect(assigns(:protocol).class).to eq Project
      end
    end

    describe 'GET destroy' do
      # TODO: method is not implemented
    end
  end
end
