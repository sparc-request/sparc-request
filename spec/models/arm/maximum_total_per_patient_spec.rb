require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#maximum_total_per_patient' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 3),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 4),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 5)]
    end

    before(:each) do
      allow(arm).to receive(:line_items_visits).and_return livs
      protocol = Protocol.new(indirect_cost_rate: 50)
      allow(arm).to receive(:protocol).and_return(protocol)
    end

    context 'with USE_INDIRECT_COST' do
      before(:each) { stub_const('USE_INDIRECT_COST', true) }

      context 'with no argument' do
        it 'should return total cost' do
          expect(arm.maximum_total_per_patient).to eq(12.0 + 6.0)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total cost' do
          expect(arm.maximum_total_per_patient livs[0..1]).to eq(7.0 + 7.0 / 2)
        end
      end
    end

    context 'without USE_INDIRECT_COST' do
      context 'with no argument' do
        it 'should return total cost' do
          expect(arm.maximum_total_per_patient).to eq(12.0)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total cost' do
          expect(arm.maximum_total_per_patient livs[0..1]).to eq(7.0)
        end
      end
    end
  end
end
