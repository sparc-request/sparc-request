require 'rails_helper'

RSpec.describe Arm, type: :model do
  describe '#maximum_direct_costs_per_patient' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 3),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 4),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 5)]
    end

    before(:each) { allow(arm).to receive(:line_items_visits).and_return livs }

    context 'with no argument' do
      it 'should return total direct cost all LineItems' do
        expect(arm.maximum_direct_costs_per_patient).to eq 12
      end
    end

    context 'with array of LineItemsVisits' do
      it 'should return total direct cost' do
        expect(arm.maximum_direct_costs_per_patient livs[0..1]).to eq 7
      end
    end
  end
end
