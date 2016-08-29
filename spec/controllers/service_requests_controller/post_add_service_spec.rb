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

  describe 'POST add_service' do

    stub_controller

    let_there_be_lane
    let_there_be_j
    build_service_request_with_study

    before(:each) do
      core.update_attribute(:process_ssrs, true)
    end

    let!(:core2) { create(:core, parent_id: program.id, process_ssrs: 1) }

    let!(:new_service) do
      service = create(:service,
                       pricing_map_count: 1,
                       one_time_fee: true,
                       organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today,
                                                quantity_minimum: 42)
      service
    end

    let!(:new_service2) do
      service = create(:service,
                       pricing_map_count: 1,
                       one_time_fee: true,
                       organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today,
                                                quantity_minimum: 54)
      service
    end

    let!(:new_service3) do
      service = create(:service,
                       pricing_map_count: 1,
                       organization_id: core2.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    end

    before do
      session[:identity_id] = jug2.id
    end

    it 'should accept params[:service_id] prefixed with "service-"' do
      post :add_service, { id: service_request.id, service_id: "service-#{new_service.id}", format: :js }
      expect(response.status).to eq 200
    end

    it 'should give an error if the ServiceRequest already has a LineItem for the Service' do
      create(:line_item,
             service_id: new_service.id,
             service_request_id: service_request.id, sub_service_request_id: sub_service_request.id)

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access
      expect(response.body).to eq 'Service exists in line items'
    end

    it 'should create a LineItem for the Service' do
      orig_count = service_request.line_items.count

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access

      service_request.reload

      expect(service_request.line_items.count).to eq orig_count + 1
      line_item = assigns(:new_line_items).first
      expect(line_item.service).to eq new_service
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 42
    end

    it 'should create a LineItem for a required service' do
      orig_count = service_request.line_items.count

      create(:service_relation,
             service_id: new_service.id,
             related_service_id: new_service2.id,
             optional: false)

      post :add_service, { id: service_request.id, service_id: new_service.id, format: :js }.with_indifferent_access

      # there was one service and one LineItem already, then we added
      # one

      service_request.reload
      expect(service_request.line_items.count).to eq orig_count + 2
      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      expect(line_item.service).to eq new_service2
      expect(line_item.optional).to eq false
      expect(line_item.quantity).to eq 54
    end

    it 'should create a LineItem for an optional Service' do
      orig_count = service_request.line_items.count

      create(:service_relation,
             service_id: new_service.id,
             related_service_id: new_service2.id,
             optional: true)

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access

      service_request.reload
      expect(service_request.line_items.count).to eq orig_count + 2

      line_item = service_request.line_items.find_by_service_id(new_service.id)
      expect(line_item.service).to eq new_service
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 42

      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      expect(line_item.service).to eq new_service2
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 54
    end

    it 'should create a SubServiceRequest for each organization in the service list' do
      orig_count = service_request.sub_service_requests.count

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
               :id          => service_request.id,
               :service_id  => service_to_add.id,
               :format      => :js
             }.with_indifferent_access
      end

      service_request.reload
      expect(service_request.sub_service_requests.count).to eq orig_count + 2
      expect(service_request.sub_service_requests[-2].organization).to eq core
      expect(service_request.sub_service_requests[-1].organization).to eq core2
    end

    it 'should update each of the LineItems with the appropriate ssr id' do
      orig_count = service_request.line_items.count

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
               :id          => service_request.id,
               :service_id  => service_to_add.id,
               :format      => :js
             }.with_indifferent_access
      end

      core_ssr = service_request.sub_service_requests.find_by_organization_id(core.id)
      core2_ssr = service_request.sub_service_requests.find_by_organization_id(core2.id)

      service_request.reload
      expect(service_request.line_items.count).to eq(orig_count + 3)
      expect(service_request.line_items[-3].sub_service_request).to eq core_ssr
      expect(service_request.line_items[-2].sub_service_request).to eq core_ssr
      expect(service_request.line_items[-1].sub_service_request).to eq core2_ssr
    end

    it 'should create a past status for the SubServiceRequest' do
      protocol = create(:study_without_validations,
                         primary_pi: jug2)

      service_request = create(:service_request_without_validations,
                               status: 'submitted',
                               protocol: protocol)

      ssr1 = create(:sub_service_request,
                    service_request_id: service_request.id,
                    status: 'submitted',
                    organization_id: core.id)
      service = create(:service,
                       organization_id: core.id)

      post :add_service, {
            id: service_request.id,
            service_id: service.id,
            format: :js
            }.with_indifferent_access

      ps1 = PastStatus.find_by(sub_service_request_id: ssr1.id)

      expect(ps1.status).to eq('submitted')
    end
  end
end
