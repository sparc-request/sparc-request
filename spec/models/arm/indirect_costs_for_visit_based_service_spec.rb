require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#indirect_costs_for_visit_based_service' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", indirect_costs_for_visit_based_service: 3),
       instance_double("LineItemsVisit", indirect_costs_for_visit_based_service: 4),
       instance_double("LineItemsVisit", indirect_costs_for_visit_based_service: 5)]
    end

    before(:each) do
      allow(arm).to receive(:line_items_visits).and_return livs
    end

    context 'with USE_INDIRECT_COST' do
      before(:each) { stub_const('USE_INDIRECT_COST', true) }

      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.indirect_costs_for_visit_based_service).to eq 12
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.indirect_costs_for_visit_based_service livs[0..1]).to eq 7
        end
      end
    end

    context 'without USE_INDIRECT_COST' do
      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.indirect_costs_for_visit_based_service).to eq 0
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.indirect_costs_for_visit_based_service livs[0..1]).to eq 0
        end
      end
    end
  end
end
