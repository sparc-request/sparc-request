require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#total_costs_for_visit_based_service' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", direct_costs_for_visit_based_service: 3, indirect_costs_for_visit_based_service: 6),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service: 4, indirect_costs_for_visit_based_service: 7),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service: 5, indirect_costs_for_visit_based_service: 8)]
    end

    before(:each) do
      allow(arm).to receive(:line_items_visits).and_return livs
    end

    context 'with USE_INDIRECT_COST' do
      before(:each) { stub_const('USE_INDIRECT_COST', true) }

      context 'with no argument' do
        it 'should return total cost' do
          expect(arm.total_costs_for_visit_based_service).to eq(3+4+5+6+7+8)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total cost' do
          expect(arm.total_costs_for_visit_based_service livs[0..1]).to eq(3+4+6+7)
        end
      end
    end

    context 'without USE_INDIRECT_COST' do
      context 'with no argument' do
        it 'should return total cost' do
          expect(arm.total_costs_for_visit_based_service).to eq(3+4+5)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total cost' do
          expect(arm.total_costs_for_visit_based_service livs[0..1]).to eq(3+4)
        end
      end
    end
  end
end
