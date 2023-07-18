require 'rails_helper'

RSpec.describe Shard::Fulfillment::LineItem, type: :model do
  describe 'associations' do
    it 'belongs to :sparc_line_item' do
      should belong_to(:sparc_line_item)
    end
    it 'belongs to :sparc_service' do
      should belong_to(:sparc_service)
    end
  end

  describe 'instance methods' do
    describe '#fulfilled?' do
      let(:service_id) { 1 }
      let(:procedure ) {{ status: 'incomplete' }}
       context 'if service is non-clinical' do
        it 'returns true' do
          allow(subject).to receive(:non_clinical?).and_return(true)
          allow(subject).to receive_message_chain(:fulfillments, :exists?).and_return(true)
          expect(subject.fulfilled?).to eq(true)
        end
      end
    end

    describe '#non_clinical?' do
      context 'when the line item is a one time fee' do
        it 'returns true' do
          allow(subject).to receive_message_chain(:sparc_line_item, :service, :one_time_fee?).and_return(true)
          expect(subject.non_clinical?).to eq(true)
        end
      end
    end

    describe '#deleted?' do
      context 'when the line item has been deleted' do
        it 'returns true' do
          allow(subject).to receive(:deleted_at).and_return(true)
          expect(subject.deleted?).to eq(true)
        end
      end
    end
  end
end
