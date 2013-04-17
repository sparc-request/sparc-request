require 'spec_helper'

describe Arm do
  it 'should be possible to create an arm' do
    arm = Arm.create!()
    arm.line_items.should eq [ ]
  end

  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_study


    before :each do
      service_request.protocol.update_attribute(:indirect_cost_rate, 200.0)
      @study = service_request.protocol
      #arm = arm1
      add_visits
    end
    describe "adding a visit" do
      it "should increase the visit count on the arm by one" do
        original_visit_count = arm1.visit_count
        arm1.add_visit
        arm1.visit_count.should eq(original_visit_count + 1)
      end

      it "should add a visit to the end if no position is specified" do
        ####TODO: I think this needs updated####
        # arm1.add_visit
        # LineItemsVisit.find(line_items_visit.id).visits.count.should eq(6)
      end

      it "should add a visit at the specified position" do
        last_visit = arm1.line_items_visits.first.visits.last
        last_visit.update_attribute(:research_billing_qty, 99)
        arm1.add_visit(3).should eq true
        arm1.visit_count.should eq 6
        arm1.line_items_visits[0].visits.count.should eq 6
        arm1.line_items_visits[1].visits.count.should eq 6
        line_items_visit.visits.map{|visit| visit.position == 6}.first.research_billing_qty.should eq(99)
      end
    end

    describe "removing a visit" do
      it "should decrease the visit count by one" do
        visit_count = arm1.visit_count
        arm1.remove_visit(1)
        arm1.visit_count.should eq(visit_count - 1)
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
        arm1.per_patient_per_visit_line_items.should include(line_item)
      end
    end

    describe "maximum direct costs per patient" do

      it "should return the total cost for all visit groupings" do
        arm1.maximum_direct_costs_per_patient.should eq(1000)
      end
    end

    describe "maximum indirect costs per patient" do

      it "should return the total indirect cost for all visit groupings if indirect cost flag is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.maximum_indirect_costs_per_patient.should eq(2000)        
      end

      it "should return zero if the indirect cost flag is not set" do
        arm1.maximum_indirect_costs_per_patient.should eq(0) 
      end
    end

    describe "maximum total per patient" do

      it "should return the total cost" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.maximum_total_per_patient.should eq(3000)
      end
    end

    describe "direct costs for visit based service" do

      it "should return total visit based costs for all visit groupings" do
        arm1.direct_costs_for_visit_based_service.should eq(5000)
      end
    end

    describe "indirect costs for visit based service" do

      it "should return total visit based indirect costs for all visit groupings" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.indirect_costs_for_visit_based_service.should eq(10000)
      end
    end

    describe "total cost for visit based service" do

      it "should return the total cost if indirect cost is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm1.total_costs_for_visit_based_service.should eq(15000)
      end

      it "should just return the direct cost if the flag is not set" do
        arm1.total_costs_for_visit_based_service.should eq(5000)
      end
    end

    describe "insure subject count" do

      it "should give the arm a subject count of 1 if the count is nil" do
        arm1.update_attributes(subject_count: nil)
        arm1.insure_subject_count
        arm1.subject_count.should eq(1)
      end

      it "should give the arm a subject count of 1 if the count is negative" do
        arm1.update_attributes(subject_count: -1)
        arm1.insure_subject_count
        arm1.subject_count.should eq(1)
      end
    end

    describe "insure visit count" do

      it "should give the arm a visit count of 1 if the count is nil" do
        arm1.update_attributes(visit_count: nil)
        arm1.insure_visit_count
        arm1.visit_count.should eq(1)
      end

      it "should give the arm a visit count of 1 if the count is negative" do
        arm1.update_attributes(visit_count: -1)
        arm1.insure_visit_count
        arm1.visit_count.should eq(1)
      end
    end

    describe 'create_line_items_visit' do
      it 'should create a line_items_visit with a subject count the same as the arm' do
        arm1.update_attributes(subject_count: 42)
        arm1.create_line_items_visit(line_item)
        arm1.line_items_visits.count.should eq 3
        arm1.line_items_visits[2].subject_count.should eq 42
      end

      it 'should create a visit grouping with new visits' do
        arm1.update_attributes(visit_count: 5)
        arm1.line_items_visits[0].create_visits
        arm1.line_items_visits[1].create_visits

        arm1.create_line_items_visit(line_item)

        # we started with 2 visit groupings; now we should have 3
        arm1.line_items_visits.count.should eq 3

        # ensure that the new visit grouping had its visits created
        arm1.line_items_visits[2].visits.count.should eq 5

        # ensure that the names are copied from the first visit grouping
        arm1.line_items_visits[2].visits[0].name.should eq arm1.line_items_visits[0].visits[0].name
        arm1.line_items_visits[2].visits[1].name.should eq arm1.line_items_visits[0].visits[1].name
        arm1.line_items_visits[2].visits[2].name.should eq arm1.line_items_visits[0].visits[2].name
        arm1.line_items_visits[2].visits[3].name.should eq arm1.line_items_visits[0].visits[3].name
        arm1.line_items_visits[2].visits[4].name.should eq arm1.line_items_visits[0].visits[4].name
      end
    end
  end
end
