require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#maximum_indirect_costs_per_patient' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 3),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 4),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 5)]
    end

    before(:each) do
      allow(arm).to receive(:line_items_visits).and_return livs
      allow(arm).to receive_message_chain(:protocol, :indirect_cost_rate).and_return 50
    end

    context 'with USE_INDIRECT_COST' do
      before(:each) { stub_const('USE_INDIRECT_COST', true) }

      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.maximum_indirect_costs_per_patient).to eq(arm.maximum_direct_costs_per_patient / 2.0)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.maximum_indirect_costs_per_patient livs[0..1]).to eq(arm.maximum_direct_costs_per_patient(livs[0..1]) / 2.0)
        end
      end
    end

    context 'without USE_INDIRECT_COST' do
      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.maximum_indirect_costs_per_patient).to eq 0.0
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.maximum_indirect_costs_per_patient livs[0..1]).to eq 0.0
        end
      end
    end
  end
end
