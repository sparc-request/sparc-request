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

RSpec.describe FeeAgreement::Report do
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
    @ssr_outpatient = create(:sub_service_request, service_request: @sr, organization: @program_outpatient_clinic, status: 'awaiting_pi_approval')
    @ssr_admin = create(:sub_service_request, service_request: @sr, organization: @program_admin, status: 'awaiting_pi_approval')
    @ssr_nursing = create(:sub_service_request, service_request: @sr, organization: @program_nursing, status: 'awaiting_pi_approval')

    # Services
    @service_outpatient_room = create(:service, :with_pricing_map, name: "Outpatient room", organization: @program_outpatient_clinic, one_time_fee: false)
    @service_general_admin_fee = create(:service, :with_pricing_map, name: "General admin fee", organization: @program_admin, one_time_fee: true)
    @service_infusion_setup = create(:service, :with_pricing_map, name: "Infusion setup", organization: @program_nursing, one_time_fee: false)
    @service_infusion_chair = create(:service, :with_pricing_map, name: "Infusion chair", organization: @program_nursing, one_time_fee: false)
    @service_nursing_admin_fee = create(:service, :with_pricing_map, name: "Nursing admin fee", organization: @program_admin, one_time_fee: true)
    @service_rn = create(:service, :with_pricing_map, name: "RN", organization: @program_nursing, one_time_fee: false)
    @service_iv = create(:service, :with_pricing_map, name: "IV", organization: @program_nursing, one_time_fee: false)

    # LineItems
    @li_outpatient_rm =  create(:line_item, :without_validations, service: @service_outpatient_room, service_request: @sr, sub_service_request: @ssr_outpatient)
    @li_general_admin =  create(:line_item, :without_validations, service: @service_general_admin_fee, service_request: @sr, sub_service_request: @ssr_admin)
    @li_infusion_setup =  create(:line_item, :without_validations, service: @service_infusion_setup, service_request: @sr, sub_service_request: @ssr_nursing)
    @li_infusion_chair =  create(:line_item, :without_validations, service: @service_infusion_chair, service_request: @sr, sub_service_request: @ssr_nursing)
    @li_nursing_admin = create(:line_item, :without_validations, service: @service_nursing_admin_fee, service_request: @sr, sub_service_request: @ssr_admin)
    @li_rn =  create(:line_item, :without_validations, service: @service_rn, service_request: @sr, sub_service_request: @ssr_nursing)
    @li_iv =  create(:line_item, :without_validations, service: @service_iv, service_request: @sr, sub_service_request: @ssr_nursing)

    # Arms
    # NOTE: The after_create callback ensures the creation of the following records:
    #   - VisitGroups: based on the visit_count, one for each visit day; total of 3.
    #   - LineItemVisits (1 for each LineItem in the protocol that's not a one time fee: total of 5 in this case);
    #   - Visit: 1 for each visit_group/line_item combination; total of 15.
    #
    @arm1 = create(:arm_without_validations, visit_count: 3, subject_count: 5, protocol: @protocol)
    @arm2 = create(:arm_without_validations, visit_count: 3, subject_count: 5, protocol: @protocol)

    # Update billing quantity data for the visits from the default values of 0.
    # arm, day, line_item, quantity
    @visit_quantities = [
      [@arm1, 1, @li_outpatient_rm, 0],
      [@arm1, 1, @li_infusion_setup, 1],
      [@arm1, 1, @li_infusion_chair, 6],
      [@arm1, 1, @li_rn, 2],
      [@arm1, 1, @li_iv, 1],
      [@arm1, 2, @li_outpatient_rm, 0],
      [@arm1, 2, @li_infusion_setup, 0],
      [@arm1, 2, @li_infusion_chair, 6],
      [@arm1, 2, @li_rn, 0],
      [@arm1, 2, @li_iv, 0],
      [@arm1, 3, @li_outpatient_rm, 0],
      [@arm1, 3, @li_infusion_setup, 1],
      [@arm1, 3, @li_infusion_chair, 5],
      [@arm1, 3, @li_rn, 2],
      [@arm1, 3, @li_iv, 1],
      [@arm2, 1, @li_outpatient_rm, 6],
      [@arm2, 1, @li_infusion_setup, 1],
      [@arm2, 1, @li_infusion_chair, 0],
      [@arm2, 1, @li_rn, 12],
      [@arm2, 1, @li_iv, 1],
      [@arm2, 2, @li_outpatient_rm, 6],
      [@arm2, 2, @li_infusion_setup, 0],
      [@arm2, 2, @li_infusion_chair, 0],
      [@arm2, 2, @li_rn, 0],
      [@arm2, 2, @li_iv, 0],
      [@arm2, 3, @li_outpatient_rm, 5],
      [@arm2, 3, @li_infusion_setup, 1],
      [@arm2, 3, @li_infusion_chair, 0],
      [@arm2, 3, @li_rn, 8],
      [@arm2, 3, @li_iv, 1]
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

    @arm1.reload
    @arm2.reload
  end

  context 'report creation' do
    let(:report) { FeeAgreement::Report.new(@sr) }

    it 'should create a table for non-clinical services' do
      expect(report.non_clinical_service_table.class).to eq(FeeAgreement::NonClinicalServiceTable)
    end
    it 'should create a row in the non-clinical service table for every active otf line item' do
      expect(report.non_clinical_service_table.rows.count).to eq(2)
    end
    it 'should create a clinical service table for each arm' do
      expect(report.clinical_service_tables.size).to eq(2)
    end

    it 'computes a clinical service total' do
      arm, _day, li, qty = 0, 1, 2, 3
      arm1_per_person = @visit_quantities.select { |row| row[arm] == @arm1 }
                                         .map { |row| row[li].applicable_rate * row[qty] }
                                         .sum
      arm2_per_person = @visit_quantities.select { |row| row[arm] == @arm2 }
                                         .map { |row| row[li].applicable_rate * row[qty] }
                                         .sum
      amount = (arm1_per_person * @arm1.subject_count) + (arm2_per_person * @arm2.subject_count)
      expect(report.clinical_total).to eq(Service.cents_to_dollars(amount))
    end

    it 'computes a grand total' do
      non_clin_total = @sr.line_items.select(&:one_time_fee)
                          .map { |li| li.applicable_rate * li.quantity }
                          .sum
      non_clin_dollars = Service.cents_to_dollars(non_clin_total)
      expect(report.grand_total).to eq(non_clin_dollars + report.clinical_total)
    end
  end

  context 'filter options' do
    let(:report) { FeeAgreement::Report.new(@sr) }
    let(:filters) { report.filter_options }
    it 'should provide options to filter on status and program' do
      expect(filters.keys).to contain_exactly(:status, :program)
    end

    it 'should only provide options for service request programs' do
      expected_programs = { @program_outpatient_clinic.id => @program_outpatient_clinic.name,
                            @program_nursing.id => @program_nursing.name,
                            @program_admin.id => @program_admin.name }
      expect(filters[:program]).to eq(expected_programs)
    end
  end

  context 'report configuration' do
    context 'with max visit columns set' do
      let (:report) { FeeAgreement::Report.new(@sr, filters = {}, max_visit_columns_per_table = 2) }

      it 'should should allow visits to be partitioned across multiple tables' do
        expect(report.clinical_service_tables.size).to eq(4)
      end

      it 'should limit the number of visit columns per table' do
        visit_columns = report.clinical_service_tables.map { |tbl| tbl.visit_columns.count }
        expect(visit_columns.max).to eq(2)
        expect(visit_columns.min).to eq(1)
      end

      it 'should only display summary columns in the final table for an arm' do
        arm1_tables = report.clinical_service_tables.select { |tbl| tbl.arm == @arm1 }
        expect(arm1_tables[0].visit_columns.count).to be(2)
        expect(arm1_tables[1].visit_columns.count).to be(1)
        expect(arm1_tables[0].last_table_for_arm).to be(false)
        expect(arm1_tables[1].last_table_for_arm).to be(true)
      end
    end

    context 'with program filter' do
      let (:report) { FeeAgreement::Report.new(@sr, filters = { :program => [@program_outpatient_clinic.id] }) }

      it 'should only display line items provided by the given program' do
        expect(report.non_clinical_service_table.rows.count).to eq(0)
        expect(report.clinical_service_tables[0].rows.count).to eq(0)
        expect(report.clinical_service_tables[1].rows.count).to eq(1)
      end

      it 'should only include selected program data in computed totals' do
        li, qty = 2, 3
        per_person = @visit_quantities.select { |row| row[li] == @li_outpatient_rm }
                                      .map { |row| row[li].applicable_rate * row[qty] }
                                      .sum
        expected = Service.cents_to_dollars(@arm2.subject_count * per_person)
        expect(report.non_clinical_service_table.total).to eq(0)
        expect(report.clinical_service_tables[0].total).to eq(0)
        expect(report.clinical_service_tables[1].total).to eq(expected)
      end
    end
  end
end
