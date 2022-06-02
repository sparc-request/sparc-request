# Copyright © 2011-2020 MUSC Foundation for Research Development
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
RSpec.describe FeeAgreement::ClinicalServiceTable do
  before :all do
    @protocol = create(:protocol_federally_funded)
    @sr = create(:service_request_without_validations, protocol: @protocol)
    # Organizations
    @inst = create(:institution, process_ssrs: false)
    @provider_ctrc = create(:provider, :with_pricing_setup, parent: @inst, process_ssrs: false)
    @program_outpatient_clinic = create(:program, parent: @provider_ctrc, process_ssrs: true)
    @program_nursing = create(:program, parent: @provider_ctrc, process_ssrs: true)
    @program_admin = create(:program, parent: @provider_ctrc, process_ssrs: true)

    # SubServiceRequests
    @ssr_outpatient = create(:sub_service_request, service_request: @sr, organization: @program_outpatient_clinic, status: 'not_draft')
    @ssr_admin = create(:sub_service_request, service_request: @sr, organization: @program_admin, status: 'not_draft')
    @ssr_nursing = create(:sub_service_request, service_request: @sr, organization: @program_nursing, status: 'not_draft')

    # Services
    @service_outpatient_room = create(:service, :with_pricing_map, name: "Outpatient room", organization: @program_outpatient_clinic, one_time_fee: false)
    @service_infusion_setup = create(:service, :with_pricing_map, name: "Infusion setup", organization: @program_nursing, one_time_fee: false)
    @service_rn = create(:service, :with_pricing_map, name: "RN", organization: @program_nursing, one_time_fee: false)
    @service_iv = create(:service, :with_pricing_map, name: "IV", organization: @program_nursing, one_time_fee: false)

    # LineItems
    @li_outpatient_rm = create(:line_item, :without_validations, service: @service_outpatient_room, service_request: @sr, sub_service_request: @ssr_outpatient)
    @li_infusion_setup = create(:line_item, :without_validations, service: @service_infusion_setup, service_request: @sr, sub_service_request: @ssr_nursing)
    @li_rn =  create(:line_item, :without_validations, service: @service_rn, service_request: @sr, sub_service_request: @ssr_nursing)
    @li_iv =  create(:line_item, :without_validations, service: @service_iv, service_request: @sr, sub_service_request: @ssr_nursing)

    # Arms
    # NOTE: The after_create callback ensures the creation of the following records:
    #   - VisitGroups: based on the visit_count, one for each visit day; total of 3.
    #   - LineItemVisits (1 for each LineItem in the protocol that's not a one time fee: total of 4 in this case);
    #   - Visit: 1 for each visit_group/line_item combination; total of 12.
    #
    @arm = create(:arm_without_validations, visit_count: 3, subject_count: 5, protocol: @protocol)

    # Update billing quantity data for the visits from the default values of 0.
    # arm, day, line_item, quantity
    @visit_quantities = [
      [@arm, 1, @li_outpatient_rm, 6],
      [@arm, 1, @li_infusion_setup, 1],
      [@arm, 1, @li_rn, 12],
      [@arm, 1, @li_iv, 1],
      [@arm, 2, @li_outpatient_rm, 6],
      [@arm, 2, @li_infusion_setup, 0],
      [@arm, 2, @li_rn, 0],
      [@arm, 2, @li_iv, 0],
      [@arm, 3, @li_outpatient_rm, 5],
      [@arm, 3, @li_infusion_setup, 1],
      [@arm, 3, @li_rn, 8],
      [@arm, 3, @li_iv, 1]
    ]
    @visit_quantities.each do |row|
      arm, day, li, qty = row
      if qty > 0
        arm.visits.includes(:visit_group, :line_items_visit)
           .where(visit_groups: { day: day })
           .where(line_items_visits: { line_item_id: li.id })
           .first
           .update(research_billing_qty: qty)
      end
    end

    @arm.reload
  end

  after :all do
    @protocol.destroy
    @inst.destroy
    @provider_ctrc.destroy
    @program_outpatient_clinic.destroy
    @program_nursing.destroy
    @program_admin.destroy
  end

  context('table initialization') do
    stub_config("use_fee_agreement", true)

    let(:table) {
      FeeAgreement::ClinicalServiceTable.new(
        service_request: @service_request,
        arm: @arm,
        visit_range: 1..3,
        visit_groups: @arm.visit_groups,
        last_table_for_arm: true,
        line_item_visits: @arm.line_items_visits
      )
    }

    it 'should have a name that with the Arm and included Visits' do
      expect(table.name).to eq("#{@arm.name} - Visit 1 to 3")
    end

    it 'should create a row for each clinical service with a visit quantity' do
      expect(table.rows.count).to eq(4)
    end

    it 'should be able to group rows by program' do
      expect(table.rows_by_program.keys).to contain_exactly(@program_outpatient_clinic.name, @program_nursing.name)
    end

    it 'should have a column for each visit group' do
      expect(table.visit_columns.count).to eq(@arm.visit_groups.count)
    end

    it 'should be able to compute a visit per patient sub-total for a program' do
      expected =  Service.cents_to_dollars(@li_infusion_setup.applicable_rate + (@li_rn.applicable_rate * 12) + @li_iv.applicable_rate)
      expect(table.visit_subtotal(@program_nursing.name, visit_position = 1)).to eq(expected)
    end

    it 'should be able to compute a visit per patient total' do
      day, li, qty = 1, 2, 3
      visit_position = 1
      amount = @visit_quantities.select { |row| row[day] == visit_position }
                                .map { |row| row[li].applicable_rate * row[qty] }
                                .sum
      expected = Service.cents_to_dollars(amount)
      expect(table.visit_total(visit_position)).to eq(expected)
    end

    it 'should be able to compute a total cost' do
      li, qty = 2, 3
      per_patient = @visit_quantities.map { |row| row[li].applicable_rate * row[qty] }.sum
      expected = Service.cents_to_dollars(per_patient * @arm.subject_count)
      expect(table.total).to eq(expected)
    end
  end
end
