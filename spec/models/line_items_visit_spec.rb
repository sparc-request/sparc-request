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

describe LineItemsVisit do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  it 'should be possible to create a line items visit' do
    arm = FactoryGirl.create(:arm)
    line_items_visit = FactoryGirl.create(:line_items_visit, arm_id: arm.id)
    line_items_visit.line_item.should eq nil
    line_items_visit.visits.should eq [ ]
  end

  describe "methods" do

    before :each do
      service_request.protocol.update_attributes(indirect_cost_rate: 200)
      add_visits
      @line_items_visit = arm1.line_items_visits.first
    end

    context "business methods" do
      
      let!(:service)         { FactoryGirl.create(:service, organization_id: program.id)}
      let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today) }
      let!(:pricing_map2)    { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today + 1) }

      describe "per unit cost" do  

        before(:each) do
          line_item.stub!(:applicable_rate) { 100 }
        end

        it "should return the per unit cost for full quantity with no arguments" do
          @line_items_visit.per_unit_cost.should eq(50)
        end

        it "should return 0 if the quantity is 0" do
          @line_items_visit.line_item.quantity = 0
          @line_items_visit.per_unit_cost.should eq(0)
        end

        it "should return the per unit cost for a specific quantity from arguments" do
          line_items_visit1 = @line_items_visit.dup
          line_items_visit2 = @line_items_visit.dup
          line_items_visit1.line_item.quantity = 5
          line_items_visit1.per_unit_cost.should eq(line_items_visit2.per_unit_cost(5))
        end
      end

      describe "units per package" do

        it "should select the correct pricing map based on display date" do
          pricing_map.update_attributes(unit_factor: 5)
          pricing_map2.update_attributes(unit_factor: 10)
          @line_items_visit.units_per_package.should eq(5)
        end
      end

      describe "quantity total" do

        it "should return the correct quantity" do
          @line_items_visit.quantity_total.should eq(100)
        end

        it "should return zero if the research billing qantity is zero" do
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
          end

          @line_items_visit.quantity_total.should eq(0)
        end
      end

      describe "per subject subtotals" do

        it "should return the correct cost of each visit" do
          costs = Hash.new
          @line_items_visit.visits.each do |visit|
            costs[visit.id.to_s] = 250
          end

          @line_items_visit.per_subject_subtotals.should eq(costs)
        end

        it "should return nil if the visit has no research billing" do
          research_billing = Hash.new
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
            research_billing[visit.id.to_s] = nil
          end

          @line_items_visit.per_subject_subtotals.should eq(research_billing)
        end        
      end

      describe "direct costs for visit based service single subject" do

        it "should return the correct cost for one subject" do
          @line_items_visit.direct_costs_for_visit_based_service_single_subject.should eq(2500)
        end 

        it "should return zero if the research billing quantity is zero" do
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
          end

          @line_items_visit.direct_costs_for_visit_based_service_single_subject.should eq(0)
        end
      end

      describe "direct costs for visit based services" do

        it "should return the correct cost for all subjects" do
          @line_items_visit.direct_costs_for_visit_based_service.should eq(5000)
        end
      end

      describe "direct costs for one time fee" do

        it "should return the correct direct cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          @line_items_visit.direct_costs_for_one_time_fee.should eq(250)
        end
      end

      describe "indirect cost" do

        before :each do
          stub_const("USE_INDIRECT_COST", true)
        end

        context "indirect cost rate" do

          it "should determine the indirect cost rate" do
            @line_items_visit.indirect_cost_rate.should eq(2)
          end
        end

        context "indirect costs for visit based service single subject" do

          it "should return the correct indirect cost" do
            @line_items_visit.indirect_costs_for_visit_based_service_single_subject.should eq(5000)
          end
        end

        context "indirect costs for visit based service" do

          it "should return the correct cost" do
            @line_items_visit.indirect_costs_for_visit_based_service.should eq(10000)
          end
        end

        context "indirect costs for one time fee" do

          it "should return the correct cost" do
            @line_items_visit.indirect_costs_for_one_time_fee.should eq(500)
          end
        end
      end

      describe "add visit" do

        it "should add a visit" do
          vg = arm1.visit_groups.create(position: nil)
          @line_items_visit.add_visit(vg)
          @line_items_visit.visits.count.should eq(11)
        end
      end

      describe "remove visit" do

        it "should delete a visit" do
          vg = arm1.visit_groups.create(position: nil)
          @line_items_visit.add_visit(vg)
          @line_items_visit.remove_visit(vg)
          @line_items_visit.visits.count.should eq(10)
        end
      end

      describe "remove procedures" do

        let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, ssr_id: "0002", service_request_id: service_request.id, organization_id: program.id, status: "submitted") }
        let!(:service3)             { FactoryGirl.create(:service, organization_id: program.id, name: 'Per Patient') }
        let!(:line_item3)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: sub_service_request2.id, quantity: 0) }

        before :each do
          add_visits
          build_clinical_data
        end

        it "should remove procedures when line_item_visit is destroyed" do

          liv = line_item3.line_items_visits.first

          liv.procedures.should_not eq(nil)

          liv.remove_procedures
          liv.reload

          liv.procedures.should eq([])
          line_item3.procedures.should_not eq([])
        end

      end
    end
  end
end
