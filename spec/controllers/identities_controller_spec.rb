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
require './app/controllers/identities_controller'

RSpec.describe IdentitiesController do
  let!(:service_request) { FactoryGirl.create(:service_request_without_validations) }
  let!(:identity) { create(:identity) }

  let!(:study) {
    study = Study.create(attributes_for(:protocol))
    study.save!(validate: false)
    project_role = create(
        :project_role,
        protocol_id: study.id,
        identity_id: identity.id,
        project_rights: "approve",
        role: "pi")
    study.reload
    study
  }

  let!(:project_role) {
    study.project_roles[0]
  }

  stub_controller

  before(:each) do
    # shouldn't need to mess around with a ServiceRequest
    allow(controller).to receive(:initialize_service_request) {}
  end

  describe 'GET show' do
    it 'should should set identity' do
      session[:identity_id] = identity.id
      xhr :get, :show, { id: identity.id, format: :js }.with_indifferent_access
      expect(assigns(:identity)).to eq identity
    end

    it 'should set can_edit to false if there are no project role params' do
      session[:identity_id] = identity.id
      xhr :get, :show, { id: identity.id, format: :js }.with_indifferent_access
      expect(assigns(:can_edit)).to eq false
    end

    it 'should set can_edit to true if there are project role params' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :show, {
        format: :js,
        id: identity.id,
        study: {
          project_roles_attributes: {
            identity.id.to_s => {
              'id' => nil,
            }
          }
        }
      }.with_indifferent_access
      expect(assigns(:can_edit)).to eq true
    end

    it 'should create a new project role if no id is given' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :show, {
        format: :js,
        id: identity.id,
        study: {
          project_roles_attributes: {
            identity.id.to_s => {
              'id' => nil,
            }
          }
        }
      }.with_indifferent_access
      expect(assigns(:project_role).class).to eq ProjectRole
      expect(assigns(:project_role).persisted?).to eq false
    end

    it 'should use the given project role if an id is given' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :show, {
        format: :js,
        id: identity.id,
        study: {
          project_roles_attributes: {
            identity.id.to_s => {
              id: project_role.id,
              role: 'pi',
              project_rights: 'jack squat',
            }.with_indifferent_access
          }
        }
      }.with_indifferent_access

      expect(assigns(:project_role)).to eq project_role
      expect(assigns(:project_role).project_rights).to eq 'jack squat'
    end
  end

  describe 'POST add_to_protocol' do
    it 'should set can_edit to true if true was passed in' do
      session[:identity_id] = identity.id
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: '',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:can_edit)).to eq true
    end

    it 'should set errors if role is blank' do
      session[:identity_id] = identity.id
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: '',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:errors)[:user_role]).to eq "Role can't be blank"
    end

    it 'should set errors if role other and role_other is blank' do
      session[:identity_id] = identity.id
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: 'other',
          role_other: '',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:errors)[:user_role]).to eq "'Other' role can't be blank"
    end

    it 'should set errors if credential other and credential_other is blank' do
      session[:identity_id] = identity.id
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: 'head honcho'
        },
        identity: {
          id: identity.id,
          credentials: 'other',
          credentials_other: ''
        }
      }.with_indifferent_access
      expect(assigns(:errors)[:credentials_other]).to eq "'Other' credential can't be blank"
    end

    it 'should set protocol type' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: 'head honcho',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:protocol_type)).to eq 'study'
    end

    it 'should create a new project role if id is blank' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: nil,
          role: 'head honcho',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:project_role).class).to eq ProjectRole
      expect(assigns(:project_role).role).to eq 'head honcho'
      expect(assigns(:project_role).identity).to eq identity
      expect(assigns(:project_role).persisted?).to eq false
    end

    it 'should use the given project role if id is not blank' do
      session[:identity_id] = identity.id
      session[:protocol_type] = 'study'
      xhr :get, :add_to_protocol, {
        format: :js,
        id: identity.id,
        can_edit: true,
        project_role: {
          id: project_role.id,
          role: 'head honcho',
        },
        identity: {
          id: identity.id,
        }
      }.with_indifferent_access
      expect(assigns(:project_role).class).to eq ProjectRole
      expect(assigns(:project_role).role).to eq 'head honcho'
      expect(assigns(:project_role).identity).to eq identity
      expect(assigns(:project_role).persisted?).to eq true
    end
  end
end
