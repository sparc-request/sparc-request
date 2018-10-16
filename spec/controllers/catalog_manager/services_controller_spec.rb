# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe CatalogManager::ServicesController do
  before :each do
    provider = build_stubbed(:provider)
    program = build_stubbed(:program, parent: provider)
    allow_any_instance_of(Service).to receive(:provider).and_return(provider)
    allow_any_instance_of(Service).to receive(:program).and_return(program)
    log_in_catalog_manager_identity(obj: build_stubbed(:identity, catalog_overlord: true))
  end

  describe '#create' do
    it 'should create a service' do
      expect{
        post :create, params: { service: attributes_for(:service) }, xhr: true
      }.to change(Service, :count).by(1)
    end
  end

  describe '#update' do
    it 'should update an existing service' do
      service = create(:service, name: 'Serviceable')
      expect{
        put :update, params: { id: service.id, service: { name: 'Serve Me, Luke' } }, xhr: true
        service.reload
      }.to change(service, :name).to('Serve Me, Luke')
    end
  end

  describe '#change_components' do
    context 'new component' do
      it 'should add a component' do
        service = create(:service, components: 'a,b,c')
        expect{
          patch :change_components, params: { service_id: service.id, service: { component: 'd' } }, format: :js, xhr: true
          service.reload
        }.to change(service, :components).to('a,b,c,d')
      end
    end

    context 'remove component' do
      it 'should delete the component' do
        service = create(:service, components: 'a,b,c')
        expect{
          patch :change_components, params: { service_id: service.id, service: { component: 'c' } }, format: :js, xhr: true
          service.reload
        }.to change(service, :components).to('a,b')
      end
    end
  end

  describe '#update_epic_info' do
    it 'should update epic info' do
      service = create(:service, cpt_code: '55555')
      expect{
        patch :update_epic_info, params: { service_id: service.id, service: { cpt_code: '12345' } }, xhr: true
        service.reload
      }.to change(service, :cpt_code).to('12345')
    end
  end

  describe 'add_related_service' do
    it 'should add a service relation' do
      service = create(:service)
      related_service = create(:service)
      expect{
        post :add_related_service, params: { service_id: service.id, related_service_id: related_service }, xhr: true
        service.reload
      }.to change(service.related_services, :count).by(1)
    end
  end

  describe '#update_related_service' do
    it 'should update a service relation' do
      service = create(:service)
      related_service = create(:service)
      relation = create(:service_relation, service: service, related_service: related_service, required: true)
      expect{
        post :update_related_service, params: { service_relation_id: relation.id, service_relation: { required: false } }, xhr: true
        relation.reload
      }.to change(relation, :required).to(false)

    end
  end

  describe 'remove_related_service' do
    it 'should remove a service relation' do
      relation = create(:service_relation)
      expect{
        post :remove_related_service, params: { service_relation_id: relation.id }, xhr: true
      }.to change(ServiceRelation, :count).by(-1)
    end
  end
end
