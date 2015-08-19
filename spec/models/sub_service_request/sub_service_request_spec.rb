# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

describe 'SubServiceRequest' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  context 'fulfillment' do

    describe 'candidate_services' do

      context 'single core' do

        before :each do
          @ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          @otf = FactoryGirl.create(:service, organization_id: core.id, one_time_fee: true) # OTF Service
          @otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map))
          sub_service_request.update_attributes(organization_id: core.id)

          @ssr = sub_service_request
        end

        it 'should return a list of available services' do
          @ssr.candidate_services.should include(@ppv, @otf)
        end

        it 'should ignore unavailable services' do
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: @otf.core.id) # Disabled PPV Service
          @ssr.candidate_services.should_not include(ppv2)
        end

      end

      context 'multiple cores' do

        it 'should climb the org tree to get services' do
          core = FactoryGirl.create(:core, parent_id: program.id)
          core2 = FactoryGirl.create(:core, parent_id: program.id)
          core3 = FactoryGirl.create(:core, parent_id: program.id)

          ppv = FactoryGirl.create(:service, organization_id: core.id, name: "Per Patient Service") # PPV Service
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: core3.id) # Disabled PPV Service
          otf = FactoryGirl.create(:service, organization_id: core2.id, name: "OTF Service", one_time_fee: true) # OTF Service
          otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map))

          # ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)

          sub_service_request.candidate_services.should include(ppv, otf)
        end
      end
    end

    describe 'fulfillment line item manipulation' do

      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }

      context 'updating a line item' do

        it 'should fail if the line item is not on the sub service request' do
          lambda { sub_service_request2.update_line_item(line_item) }.should raise_exception
        end

        it 'should update the line item successfully' do
          sub_service_request.update_line_item(line_item, quantity: 50)
          line_item.quantity.should eq(50)
        end
      end

      context 'adding a line item' do

        before :each do
          @fulfillment_service = FactoryGirl.create(:service, organization_id: program.id)
          @fulfillment_service.pricing_maps.create(FactoryGirl.attributes_for(:pricing_map))
          @fulfillment_service.reload
        end

        it 'should create the line item' do
          li = sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id)
          li.service_id.should eq(@fulfillment_service.id)
          li.should_not be_new_record
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
            Procedure.count.should eq(count * 2)
          end

          it 'should roll back if it fails' do
            lambda {
              sub_service_request.stub(:in_work_fulfillment).and_raise('error')
              sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id) rescue nil
            }.should_not change(LineItem, :count)
          end
        end
      end
    end

    describe "cost calculations" do

      context "direct cost total" do

        it "should return the direct cost for services that are one time fees" do
          sub_service_request.direct_cost_total.should eq(5000)
        end

        it "should return the direct cost for services that are visit based" do
          service.update_attributes(one_time_fee: false)
          sub_service_request.direct_cost_total.should eq(0)
        end
      end

      context "indirect cost total" do

        it "should return the indirect cost for one time fees" do
          if USE_INDIRECT_COST
            sub_service_request.indirect_cost_total.should eq(1000)
          else
            sub_service_request.indirect_cost_total.should eq(0.0)
          end
        end

        it "should return the indirect cost for visit based services" do
          if USE_INDIRECT_COST
            sub_service_request.indirect_cost_total.should eq(1000)
          else
            sub_service_request.indirect_cost_total.should eq(0.0)
          end
        end
      end

      context "grand total" do

        it "should return the grand total cost of the sub service request" do
          if USE_INDIRECT_COST
            sub_service_request.grand_total.should eq(1500)
          else
            sub_service_request.grand_total.should eq(5000.0)
          end
        end
      end

      context 'effective date for cost calculations' do

        it "should use the effective pricing scheme if set" do
          sub_service_request.set_effective_date_for_cost_calculations
          sub_service_request.line_items.last.pricing_scheme.should eq('effective')
        end

        it "should use the display date if the pricing scheme is unset" do
          sub_service_request.set_effective_date_for_cost_calculations
          sub_service_request.unset_effective_date_for_cost_calculations
          sub_service_request.line_items.last.pricing_scheme.should eq('displayed')
        end
      end

      context "subsidy percentage" do

        it "should return the correct subsidy percentage" do
          sub_service_request.subsidy_percentage.should eq(50)
        end
      end

      context "subsidy organization" do

        let!(:subsidy_map2) { FactoryGirl.create(:subsidy_map, organization_id: program.id, max_dollar_cap: 100) }

        it "should return the core if max dollar cap or max percentage is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.organization.should eq(program)
        end
      end

      context "eligible for subsidy" do

        it "should return true if the organization's max dollar cap is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return true if the organization's max percentage is > 0" do
          subsidy_map.update_attributes(max_percentage: 50)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return false is organization is excluded from subsidy" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          excluded_funding_source = FactoryGirl.create(:excluded_funding_source, subsidy_map_id: subsidy_map.id, funding_source: "federal")
          sub_service_request.eligible_for_subsidy?.should eq(false)
        end
      end
    end

    describe "sub service request status" do

      let!(:org1)       { FactoryGirl.create(:organization) }
      let!(:org2)       { FactoryGirl.create(:organization) }
      let!(:ssr1)       { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: org1.id) }
      let!(:ssr2)       { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: org2.id) }
      let!(:service)    { FactoryGirl.create(:service, organization_id: org1.id) }
      let!(:service2)   { FactoryGirl.create(:service, organization_id: org2.id) }
      let!(:line_item1) { FactoryGirl.create(:line_item, sub_service_request_id: ssr1.id, service_request_id: service_request.id, service_id: service.id) }
      let!(:line_item2) { FactoryGirl.create(:line_item, sub_service_request_id: ssr2.id, service_request_id: service_request.id, service_id: service2.id) }

      before :each do
        EDITABLE_STATUSES[sub_service_request.organization.id] = ['first_draft', 'draft', 'submitted', nil, 'get_a_quote', 'awaiting_pi_approval']
      end

      context "can be edited" do

        it "should return true if the status is draft" do
          sub_service_request.update_attributes(status: "draft")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is submitted" do
          sub_service_request.update_attributes(status: "submitted")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is nil" do
          sub_service_request.update_attributes(status: nil)
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is get a quote" do
          sub_service_request.update_attributes(status: 'get_a_quote')
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return false if status is anything other than above states" do
          sub_service_request.update_attributes(status: "on_hold")
          sub_service_request.can_be_edited?.should eq(false)
        end
      end

      before :each do
        EDITABLE_STATUSES[ssr1.organization.id] = ['first_draft', 'draft', 'submitted', nil, 'get_a_quote', 'awaiting_pi_approval']
      end

      context "update based on status" do

        it "should place a sub service request under a new service request if conditions are met" do
          sr_count = service_request.protocol.service_requests.count
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          ssr1.service_request.id.should_not eq(service_request.id)
          service_request.protocol.service_requests.count.should > sr_count
        end

        it "should assign the ssrs line items to the new service request" do
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          ssr1.line_items.first.service_request_id.should_not eq(service_request.id)
          line_item2.service_request_id.should eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if there is only one ssr" do
          ssr2.destroy
          sub_service_request.destroy
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('submitted')
          ssr1.service_request.id.should eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if the ssr is not tagged with ctrc" do
          ssr2.update_attributes(status: 'on_hold')
          ssr2.update_based_on_status('submitted')
          ssr2.service_request.id.should eq(service_request.id)
        end

        it "should not place a sub service request under a new service request if the ssr is being switched to another uneditable status" do
          ssr1.update_attributes(status: 'on_hold')
          ssr1.update_based_on_status('complete')
          ssr1.service_request.id.should eq(service_request.id)
        end
      end

      context "candidate statuses" do

        before :each do
          org1.tag_list = "ctrc"
          org1.save
        end

        it "should contain 'ctrc approved' and 'ctrc review' if the organization is ctrc" do
          sub_service_request.update_attributes(organization_id: org1.id)
          sub_service_request.candidate_statuses.should include('ctrc approved', 'ctrc review')
        end

        it "should not contain ctrc statuses if the organization is not ctrc" do
          sub_service_request.update_attributes(organization_id: org2.id)
          sub_service_request.candidate_statuses.should_not include('ctrc approved', 'ctrc review')
        end
      end
    end

    describe "sub service request ownership" do

      context "candidate owners" do

        let!(:user)               { FactoryGirl.create(:identity) }

        before :each do
          provider.update_attributes(process_ssrs: true)
          program.update_attributes(process_ssrs: true)
          core.update_attributes(process_ssrs: true)
        end

        it "should return all identities associated with the sub service request's organization, children, and parents" do
          sub_service_request.candidate_owners.should include(jug2)
        end

        it "should return the owner" do
          sub_service_request.update_attributes(owner_id: user.id)
          sub_service_request.candidate_owners.should include(user, jug2)
        end

        it "should not return the same identity twice if it is both the owner and service provider" do
          sub_service_request.update_attributes(owner_id: user.id)
          sub_service_request.candidate_owners.uniq.length.should eq(sub_service_request.candidate_owners.length)
        end
      end
    end
  end
end
