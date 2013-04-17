require 'spec_helper'

describe Arm do
  it 'should be possible to create an arm' do
    arm = Arm.create!()
    arm.line_items.should eq [ ]
  end

  before :each do

    @study = FactoryGirl.build(:study, :funded, :federal, indirect_cost_rate: 200)
    @study.save(validate: false)
  end
  
  context 'fulfillment' do

    describe 'adding and removing visits' do

      let!(:service_request) { FactoryGirl.create(:service_request) }
      let!(:service)         { FactoryGirl.create(:service) }
      let!(:service2)        { FactoryGirl.create(:service) }
      let(:line_item)        { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id) }
      let(:line_item2)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id) }
      let!(:arm)             { FactoryGirl.create(:arm, service_request_id: service_request.id, subject_count: 5, visit_count: 5)}
      let!(:line_items_visit)  { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id, subject_count: 5)}
      let!(:line_items_visit2) { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item2.id, subject_count: 5)}

      before(:each) do
        5.times do
          FactoryGirl.create(:visit, line_items_visit_id: line_items_visit.id)
          FactoryGirl.create(:visit, line_items_visit_id: line_items_visit2.id)
        end
        @sr = ServiceRequest.first
        @arm = Arm.first
      end

      it "should increase the visit count on the arm by one" do
        original_visit_count = arm.visit_count
        @arm.add_visit
        @arm.visit_count.should eq(original_visit_count + 1)
      end

      it "should add a visit to the end if no position is specified" do
        @arm.add_visit
        LineItemsVisit.find(line_items_visit.id).visits.count.should eq(6)
      end

      it "should add a visit at the specified position" do
        last_visit = line_items_visit.visits.last
        last_visit.update_attribute(:research_billing_qty, 99)
        @arm.add_visit(3).should eq true
        @arm.visit_count.should eq 6
        @arm.line_items_visits[0].visits.count.should eq 6
        @arm.line_items_visits[1].visits.count.should eq 6
        line_items_visit.visits.map{|visit| visit.position == 6}.first.research_billing_qty.should eq(99)
      end

      it "should decrease the visit count by one" do
        visit_count = @arm.visit_count
        @arm.remove_visit(1)
        @arm.visit_count.should eq(visit_count - 1)
      end 

      it "should remove a visit at the specified position" do
        first_visit = line_items_visit.visits.first
        first_visit.update_attributes(billing: "your mom")
        @arm.remove_visit(1)
        new_first_visit = line_items_visit.visits.first
        new_first_visit.billing.should_not eq("your mom")
      end
    end
  end

  context "methods" do

    let!(:program)         { FactoryGirl.create(:program) }
    let!(:pricing_setup)   { FactoryGirl.create(:pricing_setup, organization_id: program.id) }
    let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
    let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id) }
    let!(:service)         { FactoryGirl.create(:service, organization_id: program.id)}
    let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today) }
    let!(:pricing_map2)    { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today + 1) }
    let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: ssr.id, service_id: service.id, quantity: 20)} 
    let!(:arm)             { FactoryGirl.create(:arm, service_request_id: service_request.id) }
    let!(:line_items_visit)  { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id, subject_count: 5) }   
    let!(:line_items_visit2) { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id, subject_count: 5) }   
    let!(:visit)           { FactoryGirl.create(:visit, line_items_visit_id: line_items_visit.id, research_billing_qty: 5)}
    let!(:visit2)          { FactoryGirl.create(:visit, line_items_visit_id: line_items_visit2.id, research_billing_qty: 5)}

    describe "per patient per visit" do

      it "should return an array of line items" do
        arm.per_patient_per_visit_line_items.should include(line_item)
      end
    end

    describe "maximum direct costs per patient" do

      it "should return the total cost for all visit groupings" do
        arm.maximum_direct_costs_per_patient.should eq(1000)
      end
    end

    describe "maximum indirect costs per patient" do

      it "should return the total indirect cost for all visit groupings if indirect cost flag is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm.maximum_indirect_costs_per_patient.should eq(2000)        
      end

      it "should return zero if the indirect cost flag is not set" do
        arm.maximum_indirect_costs_per_patient.should eq(0) 
      end
    end

    describe "maximum total per patient" do

      it "should return the total cost" do
        stub_const("USE_INDIRECT_COST", true)
        arm.maximum_total_per_patient.should eq(3000)
      end
    end

    describe "direct costs for visit based service" do

      it "should return total visit based costs for all visit groupings" do
        arm.direct_costs_for_visit_based_service.should eq(5000)
      end
    end

    describe "indirect costs for visit based service" do

      it "should return total visit based indirect costs for all visit groupings" do
        stub_const("USE_INDIRECT_COST", true)
        arm.indirect_costs_for_visit_based_service.should eq(10000)
      end
    end

    describe "total cost for visit based service" do

      it "should return the total cost if indirect cost is set" do
        stub_const("USE_INDIRECT_COST", true)
        arm.total_costs_for_visit_based_service.should eq(15000)
      end

      it "should just return the direct cost if the flag is not set" do
        arm.total_costs_for_visit_based_service.should eq(5000)
      end
    end

    describe "insure subject count" do

      it "should give the arm a subject count of 1 if the count is nil" do
        arm.update_attributes(subject_count: nil)
        arm.insure_subject_count
        arm.subject_count.should eq(1)
      end

      it "should give the arm a subject count of 1 if the count is negative" do
        arm.update_attributes(subject_count: -1)
        arm.insure_subject_count
        arm.subject_count.should eq(1)
      end
    end

    describe "insure visit count" do

      it "should give the arm a visit count of 1 if the count is nil" do
        arm.update_attributes(visit_count: nil)
        arm.insure_visit_count
        arm.visit_count.should eq(1)
      end

      it "should give the arm a visit count of 1 if the count is negative" do
        arm.update_attributes(visit_count: -1)
        arm.insure_visit_count
        arm.visit_count.should eq(1)
      end
    end

    describe 'create_line_items_visit' do
      it 'should create a visit grouping with a subject count the same as the arm' do
        arm.update_attributes(subject_count: 42)
        arm.create_line_items_visit(line_item)
        arm.line_items_visits.count.should eq 3
        arm.line_items_visits[2].subject_count.should eq 42
      end

      it 'should create a visit grouping with new visits' do
        arm.update_attributes(visit_count: 5)
        arm.line_items_visits[0].create_visits
        arm.line_items_visits[1].create_visits

        arm.create_line_items_visit(line_item)

        # we started with 2 visit groupings; now we should have 3
        arm.line_items_visits.count.should eq 3

        # ensure that the new visit grouping had its visits created
        arm.line_items_visits[2].visits.count.should eq 5

        # ensure that the names are copied from the first visit grouping
        arm.line_items_visits[2].visits[0].name.should eq arm.line_items_visits[0].visits[0].name
        arm.line_items_visits[2].visits[1].name.should eq arm.line_items_visits[0].visits[1].name
        arm.line_items_visits[2].visits[2].name.should eq arm.line_items_visits[0].visits[2].name
        arm.line_items_visits[2].visits[3].name.should eq arm.line_items_visits[0].visits[3].name
        arm.line_items_visits[2].visits[4].name.should eq arm.line_items_visits[0].visits[4].name
      end
    end
  end
end
