require 'rails_helper'

RSpec.describe Shard::Fulfillment::Appointment, type: :model do
  describe 'associations' do
    it { should have_many(:procedures) }
    it { should belong_to(:arm) }
  end

  describe 'table_name' do
    it { expect(described_class.table_name).to eq('appointments') }
  end
end
