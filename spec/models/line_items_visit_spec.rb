# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe LineItemsVisit, type: :model do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  it 'should be possible to create a line items visit' do
    arm = build(:arm)
    line_items_visit = build(:line_items_visit, arm_id: arm.id)
    expect(line_items_visit.line_item).to eq nil
    expect(line_items_visit.visits).to eq [ ]
  end

  describe "methods" do
    before :each do
      service_request.protocol.update_attributes(indirect_cost_rate: 200)
      @line_items_visit = arm1.line_items_visits.first

      service_request.arms.each { |arm| arm.visits.update_all(quantity: 15, research_billing_qty: 5, insurance_billing_qty: 5, effort_billing_qty: 5) }
    end

    context "business methods" do

      let!(:service)         { create(:service, organization_id: program.id)}
      let!(:pricing_map)     { create(:pricing_map, service_id: service.id, display_date: Date.today, effective_date: Date.today) }
      let!(:pricing_map2)    { create(:pricing_map, service_id: service.id, display_date: Date.today + 1, effective_date: Date.today + 1) }

      describe "per unit cost" do

        before(:each) do
          allow(line_item).to receive(:applicable_rate) { 100 }
        end

        it "should return the per unit cost for full quantity with no arguments" do
          expect(@line_items_visit.per_unit_cost).to eq(50)
        end

        it "should return 0 if the quantity is 0" do
          @line_items_visit.line_item.quantity = 0
          expect(@line_items_visit.per_unit_cost).to eq(0)
        end

        it "should return the per unit cost for a specific quantity from arguments" do
          line_items_visit1 = @line_items_visit.dup
          line_items_visit2 = @line_items_visit.dup
          line_items_visit1.line_item.quantity = 5
          expect(line_items_visit1.per_unit_cost).to eq(line_items_visit2.per_unit_cost(5))
        end
      end

      describe "units per package" do

        it "should select the correct pricing map based on display date" do
          pricing_map.update_attributes(unit_factor: 5)
          pricing_map2.update_attributes(unit_factor: 10)
          expect(@line_items_visit.units_per_package).to eq(5)
        end
      end

      describe "quantity total" do

        it "should return the correct quantity" do
          expect(@line_items_visit.quantity_total).to eq(100)
        end

        it "should return zero if the research billing qantity is zero" do
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
          end

          expect(@line_items_visit.quantity_total).to eq(0)
        end
      end

      describe "per subject subtotals" do

        it "should return the correct cost of each visit" do
          costs = Hash.new
          @line_items_visit.visits.each do |visit|
            costs[visit.id.to_s] = 250
          end

          expect(@line_items_visit.per_subject_subtotals).to eq(costs)
        end

        it "should return nil if the visit has no research billing" do
          research_billing = Hash.new
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
            research_billing[visit.id.to_s] = nil
          end

          expect(@line_items_visit.per_subject_subtotals).to eq(research_billing)
        end
      end

      describe "direct costs for visit based service single subject" do

        it "should return the correct cost for one subject" do
          expect(@line_items_visit.direct_costs_for_visit_based_service_single_subject).to eq(2500)
        end

        it "should return zero if the research billing quantity is zero" do
          @line_items_visit.visits.each do |visit|
            visit.update_attributes(research_billing_qty: 0)
          end

          expect(@line_items_visit.direct_costs_for_visit_based_service_single_subject).to eq(0)
        end
      end

      describe "direct costs for visit based services" do

        it "should return the correct cost for all subjects" do
          expect(@line_items_visit.direct_costs_for_visit_based_service).to eq(5000)
        end
      end

      describe "direct costs for one time fee" do

        it "should return the correct direct cost" do
          service.update_attributes(one_time_fee: true)
          expect(@line_items_visit.direct_costs_for_one_time_fee).to eq(250)
        end
      end

      describe "indirect cost" do
        stub_config("use_indirect_cost", true)

        before :each do
          study.update_attribute(:indirect_cost_rate, 200)
        end

        context "indirect cost rate" do

          it "should determine the indirect cost rate" do
            expect(@line_items_visit.indirect_cost_rate).to eq(2)
          end
        end

        context "indirect costs for visit based service single subject" do

          it "should return the correct indirect cost" do
            expect(@line_items_visit.indirect_costs_for_visit_based_service_single_subject).to eq(5000)
          end
        end

        context "indirect costs for visit based service" do

          it "should return the correct cost" do
            expect(@line_items_visit.indirect_costs_for_visit_based_service).to eq(10000)
          end
        end

        context "indirect costs for one time fee" do

          it "should return the correct cost" do
            expect(@line_items_visit.indirect_costs_for_one_time_fee).to eq(500)
          end
        end
      end
    end
  end
end
