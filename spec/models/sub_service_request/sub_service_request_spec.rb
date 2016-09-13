# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe 'SubServiceRequest' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  context 'fulfillment' do

    describe 'candidate_services' do

      context 'single core' do

        before :each do
          @ppv = create(:service, organization_id: core.id) # PPV Service
          @otf = create(:service, organization_id: core.id, one_time_fee: true) # OTF Service
          @otf.pricing_maps.build(attributes_for(:pricing_map))
          sub_service_request.update_attributes(organization_id: core.id)

          @ssr = sub_service_request
        end

        it 'should return a list of available services' do
          expect(@ssr.candidate_services).to include(@ppv, @otf)
        end

        it 'should ignore unavailable services' do
          ppv2 = create(:service, :disabled, organization_id: @otf.core.id) # Disabled PPV Service
          expect(@ssr.candidate_services).not_to include(ppv2)
        end

      end

      context 'multiple cores' do

        it 'should climb the org tree to get services' do
          core = create(:core, parent_id: program.id)
          core2 = create(:core, parent_id: program.id)
          core3 = create(:core, parent_id: program.id)

          ppv = create(:service, organization_id: core.id, name: "Per Patient Service") # PPV Service
          ppv2 = create(:service, :disabled, organization_id: core3.id) # Disabled PPV Service
          otf = create(:service, organization_id: core2.id, name: "OTF Service", one_time_fee: true) # OTF Service
          otf.pricing_maps.build(attributes_for(:pricing_map))

          # ssr = create(:sub_service_request, organization_id: core.id)

          expect(sub_service_request.candidate_services).to include(ppv, otf)
        end

      end

    end

    describe 'fulfillment line item manipulation' do

      let!(:sub_service_request2) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }

      context 'updating a line item' do

        it 'should fail if the line item is not on the sub service request' do
          expect(lambda { sub_service_request2.update_line_item(line_item) }).to raise_exception(ArgumentError)
        end

        it 'should update the line item successfully' do
          sub_service_request.update_line_item(line_item, quantity: 20)
          expect(line_item.quantity).to eq(20)
        end
      end

      context 'adding a line item' do

        before :each do
          @fulfillment_service = create(:service, organization_id: program.id)
          @fulfillment_service.pricing_maps.create(attributes_for(:pricing_map))
          @fulfillment_service.reload
        end

        it 'should create the line item' do
          li = sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id)
          expect(li.service_id).to eq(@fulfillment_service.id)
          expect(li).not_to be_new_record
        end

        context 'subject calendars exist' do

          before :each do
            add_visits
            service_request.arms.each(&:populate_subjects)
            sub_service_request.update_attribute(:in_work_fulfillment, true)
          end

          it 'should create procedures for the line item' do
            count = Procedure.count
            li = sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id)
            expect(Procedure.count).to eq(count * 2)
          end

          it 'should roll back if it fails' do
            expect {
              allow(sub_service_request).to receive(:in_work_fulfillment).and_raise('error')
              sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id) rescue nil
            }.not_to change(LineItem, :count)
          end

        end

      end
    end

    describe "cost calculations" do

      context "direct cost total" do

        it "should return the direct cost for services that are one time fees" do
          expect(sub_service_request.direct_cost_total).to eq(5000)
        end

        it "should return the direct cost for services that are visit based" do
          service.update_attributes(one_time_fee: false)
          expect(sub_service_request.direct_cost_total).to eq(0)
        end
      end

      context "indirect cost total" do

        it "should return the indirect cost for one time fees" do
          if USE_INDIRECT_COST
            expect(sub_service_request.indirect_cost_total).to eq(1000)
          else
            expect(sub_service_request.indirect_cost_total).to eq(0.0)
          end
        end

        it "should return the indirect cost for visit based services" do
          if USE_INDIRECT_COST
            expect(sub_service_request.indirect_cost_total).to eq(1000)
          else
            expect(sub_service_request.indirect_cost_total).to eq(0.0)
          end
        end
      end

      context "grand total" do

        it "should return the grand total cost of the sub service request" do
          if USE_INDIRECT_COST
            expect(sub_service_request.grand_total).to eq(1500)
          else
            expect(sub_service_request.grand_total).to eq(5000.0)
          end
        end
      end

      context 'effective date for cost calculations' do

        it "should use the effective pricing scheme if set" do
          sub_service_request.set_effective_date_for_cost_calculations
          expect(sub_service_request.line_items.last.pricing_scheme).to eq('effective')
        end

        it "should use the display date if the pricing scheme is unset" do
          sub_service_request.set_effective_date_for_cost_calculations
          sub_service_request.unset_effective_date_for_cost_calculations
          expect(sub_service_request.line_items.last.pricing_scheme).to eq('displayed')
        end
      end

      context "subsidy percentage" do

        it "should return the correct subsidy percentage" do
          expect(sub_service_request.subsidy_percentage).to eq(45)
        end
      end

      context "subsidy organization" do

        let!(:subsidy_map2) { create(:subsidy_map, organization_id: program.id, max_dollar_cap: 100) }

        it "should return the core if max dollar cap or max percentage is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          expect(sub_service_request.organization).to eq(program)
        end
      end

      context "eligible for subsidy" do

        it "should return true if the organization's max dollar cap is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          expect(sub_service_request.eligible_for_subsidy?).to eq(true)
        end

        it "should return true if the organization's max percentage is > 0" do
          subsidy_map.update_attributes(max_percentage: 50)
          expect(sub_service_request.eligible_for_subsidy?).to eq(true)
        end

        it "should return false is organization is excluded from subsidy" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          excluded_funding_source = create(:excluded_funding_source, subsidy_map_id: subsidy_map.id, funding_source: "federal")
          expect(sub_service_request.eligible_for_subsidy?).to eq(false)
        end
      end
    end

    describe "sub service request status" do

      let!(:org1)       { create(:organization) }
      let!(:org2)       { create(:organization) }
      let!(:ssr1)       { create(:sub_service_request, service_request_id: service_request.id, organization_id: org1.id) }
      let!(:ssr2)       { create(:sub_service_request, service_request_id: service_request.id, organization_id: org2.id) }
      let!(:service)    { create(:service, organization_id: org1.id) }
      let!(:service2)   { create(:service, organization_id: org2.id) }
      let!(:line_item1) { create(:line_item, sub_service_request_id: ssr1.id, service_request_id: service_request.id, service_id: service.id) }
      let!(:line_item2) { create(:line_item, sub_service_request_id: ssr2.id, service_request_id: service_request.id, service_id: service2.id) }

      before :each do
        EDITABLE_STATUSES[sub_service_request.organization.id] = ['first_draft', 'draft', 'submitted', nil, 'get_a_cost_estimate', 'awaiting_pi_approval']
      end

      context "can be edited" do

        it "should return true if the status is draft" do
          sub_service_request.update_attributes(status: "draft")
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return true if the status is submitted" do
          sub_service_request.update_attributes(status: "submitted")
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return true if the status is nil" do
          sub_service_request.update_attributes(status: nil)
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return true if the status is get a cost estimate" do
          sub_service_request.update_attributes(status: 'get_a_cost_estimate')
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return false if status is anything other than above states" do
          sub_service_request.update_attributes(status: "on_hold")
          expect(sub_service_request.can_be_edited?).to eq(false)
        end
      end

      before :each do
        EDITABLE_STATUSES[ssr1.organization.id] = ['first_draft', 'draft', 'submitted', nil, 'get_a_cost_estimate', 'awaiting_pi_approval']
      end

      context "update based on status" do

        it "should place a sub service request under a new service request if conditions are met" do
          sr_count = service_request.protocol.service_requests.count
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          expect(ssr1.service_request.id).not_to eq(service_request.id)
          expect(service_request.protocol.service_requests.count).to be > sr_count
        end

        it "should assign the ssrs line items to the new service request" do
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          expect(ssr1.line_items.first.service_request_id).not_to eq(service_request.id)
          expect(line_item2.service_request_id).to eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if there is only one ssr" do
          ssr2.destroy
          sub_service_request.destroy
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          expect(ssr1.service_request.id).to eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if the ssr is not tagged with ctrc" do
          ssr2.update_attributes(status: 'on_hold')
          ssr2.update_based_on_status('submitted')
          expect(ssr2.service_request.id).to eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if the ssr is being switched to another uneditable status" do
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('complete')
          expect(ssr1.service_request.id).to eq(service_request.id)
        end
      end

      context "candidate statuses" do

        before :each do
          org1.tag_list = "ctrc"
          org1.save
        end

        it "should contain 'ctrc approved' and 'ctrc review' if the organization is ctrc" do
          sub_service_request.update_attributes(organization_id: org1.id)
          expect(sub_service_request.candidate_statuses).to include('ctrc approved', 'ctrc review')
        end

        it "should not contain ctrc statuses if the organization is not ctrc" do
          sub_service_request.update_attributes(organization_id: org2.id)
          expect(sub_service_request.candidate_statuses).not_to include('ctrc approved', 'ctrc review')
        end
      end
    end

    describe "sub service request ownership" do

      context "candidate owners" do

        let!(:user)               { create(:identity) }

        before :each do
          provider.update_attributes(process_ssrs: true)
          program.update_attributes(process_ssrs: true)
          core.update_attributes(process_ssrs: true)
        end

        it "should return all identities associated with the sub service request's organization, children, and parents" do
          expect(sub_service_request.candidate_owners).to include(jug2)
        end

        it "should return the owner" do
          sub_service_request.update_attributes(owner_id: user.id)
          expect(sub_service_request.candidate_owners).to include(user, jug2)
        end

        it "should not return the same identity twice if it is both the owner and service provider" do
          sub_service_request.update_attributes(owner_id: user.id)
          expect(sub_service_request.candidate_owners.uniq.length).to eq(sub_service_request.candidate_owners.length)
        end
      end
    end
  end
end
