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
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  describe 'GET service_calendar' do
    let!(:service) do
      service = create(:service, pricing_map_count: 1)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    end

    let!(:one_time_fee_service) do
      service = create(:service, pricing_map_count: 1, one_time_fee: true)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    end

    let!(:pricing_map)              { service.pricing_maps[0] }
    let!(:one_time_fee_pricing_map) { one_time_fee_service.pricing_maps[0] }

    let!(:line_item)                { create(:line_item, service_id: service.id, service_request_id: service_request.id) }
    let!(:one_time_fee_line_item)   { create(:line_item, service_id: service.id, service_request_id: service_request.id) }

    context 'page passed in params[:pages]' do
      it 'should set the page' do
        arm1.update_attribute(:visit_count, 5)
        get :service_calendar, { id: service_request.id, pages: { arm1.id.to_s => 42 } }.with_indifferent_access
        expect(session[:service_calendar_pages]).to eq(arm1.id.to_s => '42')
      end
    end

    context 'Arm have no LineItemsVisits' do
      it 'should create LineItemsVisits for Arm' do
        arm1.line_items_visits.each(&:destroy)
        get :service_calendar, id: service_request.id
        expect(arm1.reload.line_items_visits).to_not be_empty
      end
    end

    context 'Arm has LineItemVisits' do
      let!(:liv) { LineItemsVisit.for(arm1, line_item) }
      context 'LineItemsVisit subject_count not set' do
        it 'should set subject count on the per patient per visit line items' do
          arm1.update_attribute(:subject_count, 5)

          liv.update_attribute(:subject_count, nil)
          get :service_calendar, { id: service_request.id, pages: { arm1.id => 42 } }.with_indifferent_access
          liv.reload

          expect(liv.subject_count).to eq 5
        end
      end

      context 'LineItemsVisit subject_count exceeds Arm subject_count' do
        it 'should set subject count on the per patient per visit line items' do
          arm1.update_attribute(:subject_count, 5)

          liv.update_attribute(:subject_count, 6)
          get :service_calendar, { id: service_request.id, pages: { arm1.id => 42 } }.with_indifferent_access

          liv.reload
          expect(liv.subject_count).to eq 5
        end
      end

      context 'LineItemsVisit subject_count set and smaller than Arm subject_count' do
        it 'should NOT set subject count on the per patient per visit line items' do
          arm1.update_attribute(:subject_count, 5)

          liv.update_attribute(:subject_count, 4)
          get :service_calendar, { id: service_request.id, pages: { arm1.id => 42 } }.with_indifferent_access
          liv.reload
          expect(liv.subject_count).to eq 4
        end
      end

      context "status of ServiceRequest is 'first_draft'" do
        it 'should set subject count on the per patient per visit line items' do
          service_request.update_attributes(status: 'first_draft')
          arm1.update_attribute(:subject_count, 5)

          liv.update_attribute(:subject_count, 4)

          session[:service_request_id] = service_request.id
          get :service_calendar, { id: service_request.id, pages: { arm1.id => 42 } }.with_indifferent_access

          liv.reload
          expect(liv.subject_count).to eq 5
        end
      end

      context 'Per patient per visit line item lacking visits' do
        it 'should create visits if too few on per patient per visit line items' do
          arm1.update_attribute(:visit_count, 5)

          add_visits_to_arm_line_item(arm1, line_item, 0)

          get :service_calendar, { id: service_request.id, pages: { arm1.id => 42 } }.with_indifferent_access

          liv.reload
          expect(liv.visits.count).to eq 5
        end
      end
    end
  end

  def add_visits_to_arm_line_item(arm, line_item, n = arm.visit_count)
    line_items_visit = LineItemsVisit.for(arm, line_item)

    n.times do |index|
      create(:visit_group, arm_id: arm.id, day: index)
    end

    n.times do |index|
      create(:visit, quantity: 0, line_items_visit_id: line_items_visit.id, visit_group_id: arm.visit_groups[index].id)
    end
  end
end
