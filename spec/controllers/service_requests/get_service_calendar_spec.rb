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
