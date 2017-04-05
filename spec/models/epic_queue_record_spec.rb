require 'rails_helper'

RSpec.describe EpicQueueRecord, type: :model do

  it { is_expected.to belong_to(:protocol) }

  it { is_expected.to belong_to(:identity) }

  describe '#with_valid_protocols' do

    it 'should return eqrs with valid protocols' do
      identity = create(:identity)
      protocol = create(:protocol, :without_validations)
      valid_eqr = create(:epic_queue_record,
                         protocol: protocol,
                         identity: identity
                        )
      create(:epic_queue_record, identity: identity)

      result = EpicQueueRecord.with_valid_protocols

      expect(result).to eq [valid_eqr]
    end
  end
end
