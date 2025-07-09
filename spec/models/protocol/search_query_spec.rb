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

    context "when searching by Service attrs" do
      let!(:cpt_eap) do
        protocol = create(:protocol_without_validations)
        sr = create(:service_request_without_validations, protocol: protocol)
        cpt = create(:service_without_validations, cpt_code: '123')
        eap = create(:service_without_validations, eap_id: '456')
        name = create(:service_without_validations, name: "Service with a cpt code")
        create(:line_item_without_validations, service_request: sr, service: cpt)
        create(:line_item_without_validations, service_request: sr, service: eap)
        create(:line_item_without_validations, service_request: sr, service: name)
        protocol
      end

      let!(:no_cpt_eap) do
        protocol = create(:protocol_without_validations)
        sr = create(:service_request_without_validations, protocol: protocol)
        no_cpt = create(:service_without_validations, name: "Service without cpt code", cpt_code: nil, eap_id: nil)
        create(:line_item_without_validations, service_request: sr, service: no_cpt)
        protocol
      end
      context "by cpt/eap" do
        it "should return protocols by service cpt code" do
          search_attrs = OpenStruct.new(search_drop: 'CPT/EAP Code', search_text: '123')
          results = Protocol.search_query(search_attrs)

          expect(results).to include(cpt_eap)
          expect(results).not_to include(no_cpt_eap)
        end
        it "should return protocols by service eap id" do
          search_attrs = OpenStruct.new(search_drop: 'CPT/EAP Code', search_text: '456')
          results = Protocol.search_query(search_attrs)

          expect(results).to include(cpt_eap)
          expect(results).not_to include(no_cpt_eap)
        end
      end
      context "by service name" do
        it "should return protocols by service name" do
          search_attrs = OpenStruct.new(search_drop: 'Service', search_text: 'Service with a cpt code')
          results = Protocol.search_query(search_attrs)

          expect(results).to include(cpt_eap)
          expect(results).not_to include(no_cpt_eap)

          search_attrs = OpenStruct.new(search_drop: 'Service', search_text: 'Service without cpt code')
          results = Protocol.search_query(search_attrs)
          expect(results).to include(no_cpt_eap)
          expect(results).not_to include(cpt_eap)
        end
      end
    end
  end
end
