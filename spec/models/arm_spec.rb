require 'spec_helper'

describe Arm do
  it 'should be possible to create an arm' do
    arm = Arm.create!()
    arm.line_items.should eq [ ]
  end

  #TODO: This needs to be a unit test on the protocol, not arm.  Also, create_arm
  #no longer actually builds subjects
  # context 'clinical work fulfillment' do
  #   let_there_be_lane
  #   let_there_be_j
  #   build_service_request_with_study


  #   before :each do
  #     add_visits
  #     sub_service_request.update_attribute(:in_work_fulfillment, true)
  #     sub_service_request.reload
  #   end

  #   it 'should populate its subjects if it has a sub service request in cwf status' do
  #     arm = service_request.protocol.create_arm(subject_count: 5, visit_count: 5, name: 'CWF ARM')
  #     arm.subjects.count.should eq(5)
  #   end

  # end

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
        arm1.visit_count.should eq(original_visit_count + 1)
      end

      it "should add a visit to the end if no position is specified" do
        #Save current last visit, current visit_count, etc...
        last_visit = arm1.line_items_visits.first.visits.last
        visit_count = arm1.visit_count
        #Add a visit to the end (hopefully)
        arm1.add_visit nil, 20, 0
        #Our count should have gone up, and there should be one more visit
        arm1.visit_count.should eq(visit_count + 1)
        arm1.line_items_visits.first.visits.count.should eq(visit_count + 1)
        #The new visit should be the last visit, so the old one should no longer be last
        arm1.line_items_visits.first.visits.last.should_not eq(last_visit)
      end

      it "should add a visit at the specified position" do
        #Change something on last visit
        arm1.line_items_visits.first.visits.last.update_attribute(:research_billing_qty, 99)
        #Add visit in the middle-ish
        arm1.add_visit(3, 3, 0).should eq true
        #There should now be an additional visit (10 originally from the fixtures)
        arm1.visit_count.should eq 11
        arm1.line_items_visits[0].visits.count.should eq 11
        #Check if the "last visit" is still the last visit (If the changed thing is the correct value)
        arm1.line_items_visits.first.visits.last.research_billing_qty.should eq(99)
      end
    end

    describe "removing a visit" do
      it "should decrease the visit count by one" do
        visit_count = arm1.visit_count
        arm1.remove_visit(1)
        arm1.visit_count.should eq(visit_count - 1)
        arm1.line_items_visits.first.visits.count.should eq(visit_count - 1)
      end 

      it "should remove a visit at the specified position" do
        first_visit = arm1.line_items_visits.first.visits.first
        first_visit.update_attributes(billing: "your mom")
        arm1.remove_visit(1)
        new_first_visit = arm1.line_items_visits.first.visits.first
        new_first_visit.billing.should_not eq("your mom")
      end
    end

    describe "per patient per visit" do

      it "should return an array of line items" do
        arm1.per_patient_per_visit_line_items.should include(line_item2)
      end
    end

    describe "maximum direct costs per patient" do

      it "should return the total cost for all line_items_visits" do
        arm1.maximum_direct_costs_per_patient.should eq(150000)
      end
    end

    describe "maximum indirect costs per patient" do

      it "should return the total indirect cost for all line_items_visits if indirect cost flag is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.maximum_indirect_costs_per_patient.should eq(300000)        
      end

      it "should return zero if the indirect cost flag is not set" do
        arm1.maximum_indirect_costs_per_patient.should eq(0) 
      end
    end

    describe "maximum total per patient" do

      it "should return the total cost" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.maximum_total_per_patient.should eq(450000)
      end
    end

    describe "direct costs for visit based service" do

      it "should return total visit based costs for all line_items_visits" do
        arm1.direct_costs_for_visit_based_service.should eq(300000)
      end
    end

    describe "indirect costs for visit based service" do

      it "should return total visit based indirect costs for all line_items_visits" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.indirect_costs_for_visit_based_service.should eq(600000)
      end
    end

    describe "total cost for visit based service" do

      it "should return the total cost if indirect cost is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.total_costs_for_visit_based_service.should eq(900000)
      end

      it "should just return the direct cost if the flag is not set" do
        arm1.total_costs_for_visit_based_service.should eq(300000)
      end
    end

    describe 'create_line_items_visit' do
      before :each do
        @line_item3 = FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id, quantity: 0)
      end

      it 'should create a line_items_visit with a subject count the same as the arm' do
        arm1.update_attributes(subject_count: 42)
        arm1.create_line_items_visit(@line_item3)
        arm1.line_items_visits.count.should eq 2
        arm1.line_items_visits.last.subject_count.should eq(arm1.subject_count)
      end

      it 'should create a line_items_visit with new visits' do
        #We started with 1 line_items_visit; now we should have 2
        arm1.create_line_items_visit(@line_item3)
        arm1.line_items_visits.count.should eq 2

        #Ensure that the new line_items_visit had its visits created
        arm1.line_items_visits.last.visits.count.should eq(arm1.visit_count)

        #Go through new visits, and ensure they are connected to the correct visit_group (visit.position simply points to position on the visit_group)
        arm1.line_items_visits.last.visits.each_with_index do |visit,position|
          #Compare position of visit to index. It's bumped up one because acts_as_list starts from 1, not 0.
          visit.position.should eq(position + 1)
        end
      end
    end
  end
end
