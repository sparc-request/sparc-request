require 'rails_helper'

RSpec.describe Protocol, type: :model do
  describe 'scope :search_query' do
    context 'when searching by NCT#' do
      let!(:protocol_with_nct) do
        protocol = create(:protocol_without_validations)
        create(:human_subjects_info_without_validations, protocol: protocol, nct_number: '12345')
        protocol
      end

      let!(:protocol_without_nct) { create(:protocol_without_validations) }

      it 'should return protocols with matching NCT#' do
        search_attrs = OpenStruct.new(search_drop: 'NCT#', search_text: '12345')
        results = Protocol.search_query(search_attrs)

        expect(results).to include(protocol_with_nct)
        expect(results).not_to include(protocol_without_nct)
      end

      it 'should return empty if no matching NCT# found' do
        search_attrs = OpenStruct.new(search_drop: 'NCT#', search_text: '67890')
        results = Protocol.search_query(search_attrs)

        expect(results).to be_empty
      end
    end
  end
end
