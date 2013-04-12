require 'spec_helper'

describe LineItemsVisit do

  it 'should be possible to create a visit grouping' do
    line_items_visit = LineItemsVisit.create!()
    line_items_visit.arm.should eq nil
    line_items_visit.line_item.should eq nil
    line_items_visit.visits.should eq [ ]
  end

  describe "methods" do

    let!(:program)       { FactoryGirl.create(:program) }
    let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, organization_id: program.id) }

    before :each do

      @study = FactoryGirl.build(:study, :funded, :federal, indirect_cost_rate: 200)
      @study.save(validate: false)
    end

    context "business methods" do

      let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
      let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id) }
      let!(:service)         { FactoryGirl.create(:service, organization_id: program.id)}
      let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today) }
      let!(:pricing_map2)    { FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.today + 1) }
      let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: ssr.id, service_id: service.id, quantity: 20)} 
      let!(:arm)             { FactoryGirl.create(:arm, service_request_id: service_request.id) }
      let!(:line_items_visit)  { FactoryGirl.create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id, subject_count: 5) }   
      let!(:visit)           { FactoryGirl.create(:visit, line_items_visit_id: line_items_visit.id, research_billing_qty: 5)}

      describe "per unit cost" do  

        before(:each) do
          line_item.stub!(:applicable_rate) { 100 }
        end

        it "should return the per unit cost for full quantity with no arguments" do
          line_items_visit.per_unit_cost.should eq(100)
        end

        it "should return 0 if the quantity is 0" do
          line_items_visit.line_item.quantity = 0
          line_items_visit.per_unit_cost.should eq(0)
        end

        it "should return the per unit cost for a specific quantity from arguments" do
          line_items_visit1 = line_items_visit.dup
          line_items_visit2 = line_items_visit.dup
          line_items_visit1.line_item.quantity = 5
          line_items_visit1.per_unit_cost.should eq(line_items_visit2.per_unit_cost(5))
        end
      end

      describe "units per package" do

        it "should select the correct pricing map based on display date" do
          pricing_map.update_attributes(unit_factor: 5)
          pricing_map2.update_attributes(unit_factor: 10)
          line_items_visit.units_per_package.should eq(5)
        end
      end

      describe "quantity total" do

        it "should return the correct quantity" do
          line_items_visit.quantity_total.should eq(25)
        end

        it "should return zero if the research billing qantity is zero" do
          visit.update_attributes(research_billing_qty: 0)
          line_items_visit.quantity_total.should eq(0)
        end
      end

      describe "per subject subtotals" do

        it "should return the correct cost of each visit" do
          line_items_visit.per_subject_subtotals.should eq( {visit.id.to_s => 500.0} )
        end

        it "should return nil if the visit has no research billing" do
          visit.update_attributes(research_billing_qty: 0)
          line_items_visit.per_subject_subtotals.should eq( {visit.id.to_s => nil} )
        end        
      end

      describe "direct costs for visit based service single subject" do

        it "should return the correct cost for one subject" do
          line_items_visit.direct_costs_for_visit_based_service_single_subject.should eq(500)
        end 

        it "should return zero if the research billing quantity is zero" do
          visit.update_attributes(research_billing_qty: 0)
          line_items_visit.direct_costs_for_visit_based_service_single_subject.should eq(0)
        end
      end

      describe "direct costs for visit based services" do

        it "should return the correct cost for all subjects" do
          line_items_visit.direct_costs_for_visit_based_service.should eq(2500)
        end
      end

      describe "direct costs for one time fee" do

        it "should return the correct direct cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          line_items_visit.direct_costs_for_one_time_fee.should eq(2000)
        end
      end

      describe "indirect cost" do

        before :each do
          stub_const("USE_INDIRECT_COST", true)
        end

        context "indirect cost rate" do

          it "should determine the indirect cost rate" do
            line_items_visit.indirect_cost_rate.should eq(2)
          end
        end

        context "indirect costs for visit based service single subject" do

          it "should return the correct indirect cost" do
            line_items_visit.indirect_costs_for_visit_based_service_single_subject.should eq(1000)
          end
        end

        context "indirect costs for visit based service" do

          it "should return the correct cost" do
            line_items_visit.indirect_costs_for_visit_based_service.should eq(5000)
          end
        end

        context "indirect costs for one time fee" do

          it "should return the correct cost" do
            line_items_visit.indirect_costs_for_one_time_fee.should eq(4000)
          end
        end
      end

      describe "add visit" do

        it "should add a visit" do
          line_items_visit.add_visit(2)
          line_items_visit.visits.count.should eq(2)
        end
      end

      describe "remove visit" do

        it "should delete a visit" do
          line_items_visit.add_visit(2)
          line_items_visit.remove_visit(2)
          line_items_visit.visits.count.should eq(1)
        end
      end
    end
  end
end
