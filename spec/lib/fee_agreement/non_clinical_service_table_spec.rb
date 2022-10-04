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

RSpec.describe FeeAgreement::NonClinicalServiceTable do
  # Setup data
  before :all do
    arm = create(:arm_without_validations)
    @org_C = create(:organization, process_ssrs: false, name: "C")
    @org_B = create(:organization, process_ssrs: true, name: "B", parent: @org_C)
    @org_A = create(:organization, :with_pricing_setup, process_ssrs: false, name: "A", parent: @org_B)
    @service_request = create(:service_request_without_validations, :with_protocol)
    @ssr1 = create(:sub_service_request, service_request: @service_request, organization: @org_C, status: "not_draft")
    @ssr2 = create(:sub_service_request, service_request: @service_request, organization: @org_C, status: "active")

    # per_patient_per_visit_line_item
    service_pppv = create(:service, :without_validations, organization: @org_A, one_time_fee: false)
    @service_otf1 = create(:service, :without_validations, :with_pricing_map, organization: @org_A, one_time_fee: true)
    @service_otf2 = create(:service, :without_validations, :with_pricing_map, organization: @org_A, one_time_fee: true)

    # This LineItem should appear
    @li_otf1 = create(:line_item, :without_validations, service: @service_otf1, service_request: @service_request, sub_service_request: @ssr1)
    @li_otf2 = create(:line_item, :without_validations, service: @service_otf2, service_request: @service_request, sub_service_request: @ssr2)

    # Should not appear
    li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: @ssr1, service_request: @service_request)
    liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv)
    liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv)
    create(:visit, line_items_visit: @liv_pppv1, research_billing_qty: 1)
    create(:visit, line_items_visit: @liv_pppv2, research_billing_qty: 1)

    # Draft should be excluded
    draft_ssr = create(:sub_service_request, service_request: @service_request, organization: @org_A, status: "draft")
    li_otf_draft = create(:line_item, :without_validations, service: @service_otf1, service_request: @service_request, sub_service_request: @draft_ssr)

    # First Draft should be excluded
    first_draft_ssr = create(:sub_service_request, service_request: @service_request, organization: @org_A, status: "first_draft")
    li_otf_first_draft = create(:line_item, :without_validations, service: @service_otf1, sub_service_request: first_draft_ssr)

    arm.reload
    @ssr1.reload
    @ssr2.reload
  end

  after :all do
    @service_request.protocol.destroy
    @org_A.destroy
    @org_B.destroy
    @org_C.destroy
  end

  stub_config("use_fee_agreement", true)

  it('constructs a row for every active otf line item') do
    table = FeeAgreement::NonClinicalServiceTable.new(@service_request)
    expect(table.rows.count).to eq(2)

    service_names = table.rows.map(&:service_name)
    expect(service_names.include?(@service_otf1.name)).to be(true)
    expect(service_names.include?(@service_otf2.name)).to be(true)
  end

  it('provides a total for all rows') do
    table = FeeAgreement::NonClinicalServiceTable.new(@service_request)
    expected_total = (@li_otf1.applicable_rate * @li_otf1.quantity) + (@li_otf2.applicable_rate * @li_otf2.quantity)
    expect(table.total).to eq(Service.cents_to_dollars(expected_total))
  end

  it('can be filtered by status') do
    table = FeeAgreement::NonClinicalServiceTable.new(@service_request, :status => "active")
    expect(table.rows.count).to eq(1)
    expect(table.rows.first.service_name).to eq(@service_otf2.name)
  end
end
