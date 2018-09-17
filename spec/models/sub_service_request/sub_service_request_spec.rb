# coding: utf-8
# Copyright © 2011-2018 MUSC Foundation for Research Development
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

RSpec.describe SubServiceRequest, type: :model do

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
          if Setting.get_value("use_indirect_cost")
            expect(sub_service_request.indirect_cost_total).to eq(1000)
          else
            expect(sub_service_request.indirect_cost_total).to eq(0.0)
          end
        end

        it "should return the indirect cost for visit based services" do
          if Setting.get_value("use_indirect_cost")
            expect(sub_service_request.indirect_cost_total).to eq(1000)
          else
            expect(sub_service_request.indirect_cost_total).to eq(0.0)
          end
        end
      end

      context "grand total" do

        it "should return the grand total cost of the sub service request" do
          if Setting.get_value("use_indirect_cost")
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
          create(:excluded_funding_source, subsidy_map_id: subsidy_map.id, funding_source: "federal")
          expect(sub_service_request.eligible_for_subsidy?).to eq(false)
        end
      end
    end

    describe "sub service request status" do

      context "can be edited" do

        it "should return true if the status is draft" do
          sub_service_request.update_attributes(status: "draft")
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return true if the status is submitted" do
          sub_service_request.update_attributes(status: "submitted")
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return true if the status is get a cost estimate" do
          sub_service_request.organization.update_attributes(process_ssrs: true)
          sub_service_request.organization.available_statuses.where(status: "get_a_cost_estimate").first.update_attributes(selected: true)
          sub_service_request.update_attributes(status: 'get_a_cost_estimate')
          expect(sub_service_request.can_be_edited?).to eq(true)
        end

        it "should return false if status is anything other than above states" do
          sub_service_request.update_attributes(status: "incomplete")
          expect(sub_service_request.can_be_edited?).to eq(false)
        end

        it 'should should return false if the status is complete' do
          sub_service_request.update_attributes(status: 'complete')
          expect(sub_service_request.can_be_edited?).to eq(false)
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
