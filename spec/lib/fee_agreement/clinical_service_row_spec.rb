# Copyright © 2011-2022 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe FeeAgreement::ClinicalServiceRow do
  let(:protocol) { create(:protocol_federally_funded) }

  let(:arm) { create(:arm_without_validations) }
  let(:org_C) { create(:organization, process_ssrs: false, abbreviation: "C") }
  let(:org_B) { create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C) }
  let(:org_A) { create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B) }
  let(:sr) { create(:service_request_without_validations) }
  let(:ssr) { create(:sub_service_request, service_request: sr, organization: org_C, status: "not_draft") }

  let(:service_pppv) { create(:service_with_pricing_map, :without_validations, one_time_fee: false) }

  let(:li_pppv) { create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr, service_request: sr, protocol: protocol) }
  let(:liv_pppv1) { create(:line_items_visit, arm: arm, line_item: li_pppv) }
  let(:visit1_pppv1) { create(:visit, line_items_visit: liv_pppv1, research_billing_qty: 1) }
  let(:visit2_pppv1) { create(:visit, line_items_visit: liv_pppv1, research_billing_qty: 2) }

  context('construction from a LineItemsVisit and list of Visits') do
    stub_config("use_fee_agreement", true)

    context('without summary information') do
      let(:row) { FeeAgreement::ClinicalServiceRow.build(liv_pppv1, [visit1_pppv1, visit2_pppv1], show_summary = false) }
      it('sets the program name') do
        expect(row.program_name).to eq(service_pppv.organization.name)
      end

      it('sets the service name') do
        expect(row.service_name).to eq(service_pppv.name)
      end

      it('sets the service cost') do
        expect(row.service_cost).to eq(li_pppv.applicable_rate)
      end

      it('sets the unit') do
        expect(row.unit).to eq(service_pppv.displayed_pricing_map.unit_type)
      end

      it('sets the enrollment') do
        expect(row.enrollment).to eq(liv_pppv1.subject_count)
      end

      it('sets the visits') do
        expect(row.visits).to contain_exactly(visit1_pppv1, visit2_pppv1)
      end

      it('does not set the per_service_total') do
        expect(row.per_service_total).to be_nil
      end

      it('does not set the notes') do
        expect(row.service_notes).to be_nil
      end
    end

    context('with summary information') do
      let(:row) { FeeAgreement::ClinicalServiceRow.build(liv_pppv1, [visit1_pppv1, visit2_pppv1], show_summary = true) }
      it('sets the per_service_total') do
        expected = Service.cents_to_dollars(liv_pppv1.direct_costs_for_visit_based_service_single_subject * row.enrollment)
        expect(row.per_service_total).to eq(expected)
      end
    end
  end
end
