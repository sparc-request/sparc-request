require 'spec_helper'

describe LineItemsVisit do

  it 'should be possible to create a line items visit' do
    line_items_visit = LineItemsVisit.create!()
    line_items_visit.arm.should eq nil
    line_items_visit.line_item.should eq nil
    line_items_visit.visits.should eq [ ]
  end

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

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

        before :each do
          build_clinical_data
        end

        it "should remove procedures when line_item_visit is destroyed" do
          liv = line_item2.line_items_visits.first

          liv.procedures.should_not eq(nil)

          liv.remove_procedures
          liv.reload

          liv.procedures.should eq([])
          line_item2.procedures.should_not eq([])
        end

      end
    end
  end
end
