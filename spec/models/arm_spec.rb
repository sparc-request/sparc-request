# coding: utf-8
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

require 'rails_helper'

RSpec.describe Arm, type: :model do
  it 'should be possible to create an arm' do
    arm = Arm.create!()
    expect(arm.line_items).to eq [ ]
  end

  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_study


    before :each do
      service_request.protocol.update_attribute(:indirect_cost_rate, 200.0)
      add_visits
      arm1.reload
    end

    describe "adding a visit" do
      it "should increase the visit count on the arm by one" do
        original_visit_count = arm1.visit_count
        arm1.add_visit nil, 20, 0
        expect(arm1.visit_count).to eq(original_visit_count + 1)
      end

      it "should add a visit to the end if no position is specified" do
        #Save current last visit, current visit_count, etc...
        last_visit = arm1.line_items_visits.first.visits.last
        visit_count = arm1.visit_count
        #Add a visit to the end (hopefully)
        arm1.add_visit nil, 20, 0
        #Our count should have gone up, and there should be one more visit
        expect(arm1.visit_count).to eq(visit_count + 1)
        expect(arm1.line_items_visits.first.visits.count).to eq(visit_count + 1)
        #The new visit should be the last visit, so the old one should no longer be last
        expect(arm1.line_items_visits.first.visits.last).not_to eq(last_visit)
      end

      it "should add a visit at the specified position" do
        #Change something on last visit
        arm1.line_items_visits.first.visits.last.update_attribute(:research_billing_qty, 99)
        #Add visit in the middle-ish
        expect(arm1.add_visit(3, 3, 0)).to eq true
        #There should now be an additional visit (10 originally from the fixtures)
        expect(arm1.visit_count).to eq 11
        expect(arm1.line_items_visits[0].visits.count).to eq 11
        #Check if the "last visit" is still the last visit (If the changed thing is the correct value)
        expect(arm1.line_items_visits.first.visits.last.research_billing_qty).to eq(99)
      end
    end

    describe "removing a visit" do
      it "should decrease the visit count by one" do
        visit_count = arm1.visit_count
        arm1.remove_visit(1)
        expect(arm1.visit_count).to eq(visit_count - 1)
        expect(arm1.line_items_visits.first.visits.count).to eq(visit_count - 1)
      end

      it "should remove a visit at the specified position" do
        first_visit = arm1.line_items_visits.first.visits.first
        first_visit.update_attributes(billing: "your mom")
        arm1.remove_visit(1)
        new_first_visit = arm1.line_items_visits.first.visits.first
        expect(new_first_visit.billing).not_to eq("your mom")
      end

      it "should not remove a visit if there is a completed appointment associated with the visit" do
        visit_count = arm1.visit_count
        appointment = create(:appointment, visit_group_id: arm1.visit_groups.first.id, completed_at: Date.today)
        arm1.remove_visit(1)
        expect(arm1.visit_count).not_to eq(visit_count - 1)
        expect(arm1.errors.messages).to eq({:completed_appointment=>["exists for this visit."]})
      end
    end

    describe "per patient per visit" do

      it "should return an array of line items" do
        expect(arm1.per_patient_per_visit_line_items).to include(line_item2)
      end
    end

    describe "maximum direct costs per patient" do

      it "should return the total cost for all line_items_visits" do
        expect(arm1.maximum_direct_costs_per_patient).to eq(150000)
      end
    end

    describe "maximum indirect costs per patient" do

      it "should return the total indirect cost for all line_items_visits if indirect cost flag is set" do
        stub_const("USE_INDIRECT_COST", true)
        expect(arm1.maximum_indirect_costs_per_patient).to eq(300000)
      end

      it "should return zero if the indirect cost flag is not set" do
        expect(arm1.maximum_indirect_costs_per_patient).to eq(0)
      end
    end

    describe "maximum total per patient" do

      it "should return the total cost" do
        stub_const("USE_INDIRECT_COST", true)
        expect(arm1.maximum_total_per_patient).to eq(450000)
      end
    end

    describe "direct costs for visit based service" do

      it "should return total visit based costs for all line_items_visits" do
        expect(arm1.direct_costs_for_visit_based_service).to eq(300000)
      end
    end

    describe "indirect costs for visit based service" do

      it "should return total visit based indirect costs for all line_items_visits" do
        stub_const("USE_INDIRECT_COST", true)
        expect(arm1.indirect_costs_for_visit_based_service).to eq(600000)
      end
    end

    describe "total cost for visit based service" do

      it "should return the total cost if indirect cost is set" do
        stub_const("USE_INDIRECT_COST", true)
        expect(arm1.total_costs_for_visit_based_service).to eq(900000)
      end

      it "should just return the direct cost if the flag is not set" do
        expect(arm1.total_costs_for_visit_based_service).to eq(300000)
      end
    end

    describe 'create_line_items_visit' do
      before :each do
        @line_item3 = create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0)
      end

      it 'should create a line_items_visit with a subject count the same as the arm' do
        arm1.update_attributes(subject_count: 42)
        arm1.create_line_items_visit(@line_item3)
        expect(arm1.line_items_visits.count).to eq 2
        expect(arm1.line_items_visits.last.subject_count).to eq(arm1.subject_count)
      end

      it 'should create a line_items_visit with new visits' do
        #We started with 1 line_items_visit; now we should have 2
        arm1.create_line_items_visit(@line_item3)
        expect(arm1.line_items_visits.count).to eq 2

        #Ensure that the new line_items_visit had its visits created
        expect(arm1.line_items_visits.last.visits.count).to eq(arm1.visit_count)

        #Go through new visits, and ensure they are connected to the correct visit_group (visit.position simply points to position on the visit_group)
        arm1.line_items_visits.last.visits.each do |visit|
          expect(visit.position).to eq(visit.visit_group.position)
        end
      end
    end
  end
end
