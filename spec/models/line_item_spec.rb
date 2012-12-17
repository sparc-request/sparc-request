require 'spec_helper'

describe "Line Item" do

  describe 'applicable_rate' do
    it 'should raise an exception if is a pricing setup but no pricing maps' do
      organization = FactoryGirl.create(:organization, :pricing_setup_count => 1)
      organization.pricing_setups[0].display_date = Date.today - 1
      service = FactoryGirl.create(:service, :organization_id => organization.id)
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      service_request = ServiceRequest.create(FactoryGirl.attributes_for(:service_request, protocol_id: project.id), :validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      lambda { line_item.applicable_rate }.should raise_exception(ArgumentError)
    end

    it 'should raise an exception if is a pricing map but no pricing setups' do
      organization = FactoryGirl.create(:organization, :pricing_setup_count => 0)
      service = FactoryGirl.create(:service, :organization_id => organization.id, :pricing_map_count => 1)
      service.pricing_maps[0].display_date = Date.today - 1
      project = Project.create(FactoryGirl.attributes_for(:protocol))
            service_request = ServiceRequest.create(FactoryGirl.attributes_for(:service_request, protocol_id: project.id), :validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      lambda { line_item.applicable_rate }.should raise_exception(ArgumentError)
    end

    it 'should call applicable_rate on the pricing map with the applied percentage and rate type returned by the pricing setup' do
      # TODO: it's obvious by the complexity of this test that
      # applicable_rate() is doing too much, but I'm not sure how to
      # refactor it to be simpler.

      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.save(:validate => false)
      organization = FactoryGirl.create(:organization, :pricing_setup_count => 1)

      service = FactoryGirl.create(:service, :organization_id => organization.id, :pricing_map_count => 1)
      service_request = FactoryGirl.build(:service_request, protocol_id: project.id)
      service_request.save(:validate => false)
      line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id)
      line_item.service_request.protocol.stub(:funding_source_based_on_status).and_return('college')

      service.organization.pricing_setups[0] = double(:display_date => Date.today - 1)
      line_item.service.organization.pricing_setups[0].
        should_receive(:rate_type).
        with('college').
        and_return('federal')
      line_item.service.organization.pricing_setups[0].
        stub!(:applied_percentage).
        with('federal').
        and_return(0.42)

      service.pricing_maps[0] = double(:display_date => Date.today - 1)
      line_item.service.pricing_maps[0].
        should_receive(:applicable_rate).
        with('federal', 0.42)

      line_item.applicable_rate
    end
  end

  context "business methods" do

    let!(:program)       { FactoryGirl.create(:program) }
    let!(:pricing_setup) { FactoryGirl.create(:pricing_setup, organization_id: program.id) }

    before :each do

      @study = FactoryGirl.build(:study, :funded, :federal)
      @study.save(validate: false)
    end

    # before :each do
    #   @program = Program.create!(FactoryGirl.attributes_for(:organization))
    #   @program.pricing_setups.build(FactoryGirl.attributes_for(:pricing_setup)).save
    #   study = FactoryGirl.build(:protocol, :funded, :federal)
    #   study.save(:validate => false)
    #   @service_request = FactoryGirl.create(:service_request, protocol_id: study.id)
    #   @ssr = @service_request.sub_service_requests.build(FactoryGirl.attributes_for(
    #     :sub_service_request, organization_id: @program.id))
    # end


    describe "per_unit_cost" do
      let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
      let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id,
                              organization_id: program.id) }
      let!(:service)         { FactoryGirl.create(:service, organization_id: program.id) }
      let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id, is_one_time_fee: true) }
      let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, 
                              sub_service_request_id: ssr.id, service_id: service.id)}
      # before :each do
      #   service = @program.services.build(FactoryGirl.attributes_for(:service))
      #   service.save
      #   service.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee)).save
      #   @line_item = @service_request.line_items.build(FactoryGirl.attributes_for(
      #     :line_item, sub_service_request_id: @ssr.id, service_id: service.id))
      # end

      it "should return the per unit cost for full quantity with no arguments" do
        line_item.per_unit_cost.should eq(100)
      end

      it "should return 0 if the quantity is 0" do
        line_item.quantity = 0
        line_item.per_unit_cost.should eq(0)
      end

      it "should return the per unit cost for a specific quantity from arguments" do
        line_item1 = line_item2 = line_item
        line_item1.quantity = 5
        line_item1.per_unit_cost.should eq(line_item2.per_unit_cost)
      end
    end

    describe "units per package" do

      let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
      let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id,
                              organization_id: program.id) }
      let!(:service)      {FactoryGirl.create(:service)}
      let!(:pricing_map)  {FactoryGirl.create(:pricing_map, service_id: service.id)}
      let!(:pricing_map2) {FactoryGirl.create(:pricing_map, service_id: service.id, display_date: Date.parse('2040-01-01'))}
      let!(:line_item)    {FactoryGirl.create(:line_item, service_request_id: service_request.id,
                           sub_service_request_id: ssr.id, service_id: service.id)}  

      it "should select the correct pricing map based on display date" do
        pricing_map.update_attributes(unit_factor: 5)
        pricing_map2.update_attributes(unit_factor: 10)
        line_item.units_per_package.should eq(5)
      end
    end

    describe "quantity total" do
      
      let!(:line_item)    {FactoryGirl.create(:line_item, subject_count: 5)}  
      let!(:visit)        {FactoryGirl.create(:visit, line_item_id: line_item.id, research_billing_qty: 5)}

      it "should return the correct quantity" do
        line_item.quantity_total.should eq(25)
      end

      it "should return zero if the reaserch billing quantity is zero" do
        visit.update_attributes(research_billing_qty: 0)
        line_item.quantity_total.should eq(0)
      end
    end

    describe "per_subject_subtotals" do

      let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
      let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id,
                              organization_id: program.id) }

      before :each do
        service = program.services.build(FactoryGirl.attributes_for(:service))
        service.save
        service.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, federal_rate: 100)).save
        @ppv_line_item = FactoryGirl.create(:line_item, service_request_id: service_request.id,
          sub_service_request_id: ssr.id, service_id: service.id, visit_count: 5)
      end

      it "should return a hash with the cost of each visit" do
        expected_return = {}
        @ppv_line_item.visits.each do |visit|
          expected_return[visit.id.to_s] = 500
        end
        @ppv_line_item.per_subject_subtotals.should eq(expected_return)
      end

      it "should return a hash of N/As for each visit if the applicable rate is N/A" do
        expected_return = {}

        @ppv_line_item.visits.each do |visit|
          expected_return[visit.id.to_s] = "N/A"

          # In order for the stub to work, all the visits need to use
          # the same line item object.  When the visit is loaded from
          # the database, even though all visits have the same line item
          # in the database, a new LineItem instance is getting created.
          # Here we explicitly set the visit's line item to
          # @ppv_line_item so we can stub only one line item instead of
          # stubbing each individual instance.
          visit.line_item = @ppv_line_item
        end

        @ppv_line_item.stub(:applicable_rate).and_return("N/A")
        @ppv_line_item.per_subject_subtotals.should eq(expected_return)
      end

      it "should have nil as the cost of a visit that has no research billing" do
        new_visit = FactoryGirl.create(:visit, line_item_id: @ppv_line_item.id, research_billing_qty: 0)

        expected_return = {}
        @ppv_line_item.visits.each do |visit|
          expected_return[visit.id.to_s] = 500
        end
        expected_return[new_visit.id.to_s] = nil

        @ppv_line_item.per_subject_subtotals.should eq(expected_return)
      end
    end

    describe 'visit manipulation' do

      let!(:service) { FactoryGirl.create(:service) }

      context 'adding a visit' do

        let!(:line_item_with_visits) { FactoryGirl.create(:line_item, service_id: service.id, visit_count: 5) }

        it 'should add the visit in the correct position' do
          line_item_with_visits.add_visit(3)
          line_item_with_visits.visits.count.should eq(6)
          line_item_with_visits.visits.where(:position => 3).first.research_billing_qty.should eq(0)
        end
      end

      context "removing a visit" do

        let!(:line_item_with_visits) { FactoryGirl.create(:line_item, service_id: service.id, visit_count: 5) }

        it "should delete a visit in the correct position" do
        first_visit = line_item_with_visits.visits.first
        first_visit.update_attributes(billing: "your mom")
        line_item_with_visits.remove_visit(1)
        line_item_with_visits.visits.count.should eq(4)
        new_first_visit = line_item_with_visits.visits.first
        new_first_visit.billing.should_not eq("your mom")
        end
      end 
    end

    describe "cost calculations" do

      let!(:service_request) { FactoryGirl.create(:service_request, protocol_id: @study.id) }
      let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id,
                              organization_id: program.id) }
      let!(:service)       {FactoryGirl.create(:service, organization_id: program.id)}
      let!(:pricing_map)   {FactoryGirl.create(:pricing_map, service_id: service.id, unit_factor: 5)}
      let!(:line_item)     {FactoryGirl.create(:line_item, service_id: service.id,
                            service_request_id: service_request.id, subject_count: 5)}  
      let!(:visit)         {FactoryGirl.create(:visit, line_item_id: line_item.id, research_billing_qty: 5)}
      let!(:pricing_setup) {FactoryGirl.create(:pricing_setup, organization_id: program.id)}

      before :each do
        @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
        @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
        @protocol.save :validate => false
        service_request.update_attributes(protocol_id: @protocol.id)
      end

      context "direct cost for visit based service single subject" do

        it "should return the correct cost for one subject" do
          line_item.direct_costs_for_visit_based_service_single_subject.should eq(100)
        end

        it "should return zero if the research billing quantity is zero" do
          visit.update_attributes(research_billing_qty: 0)
          line_item.direct_costs_for_visit_based_service_single_subject.should eq(0)
        end
      end

      context "direct cost for visit based service" do

        it "should return the correct cost for all subjects" do
          line_item.direct_costs_for_visit_based_service.should eq(500)
        end
      end

      context "direct costs for one time fee" do

        it "should return the correct direct cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          line_item.direct_costs_for_one_time_fee.should eq(200)          
        end

        it "should return zero if quantity is nil" do
          line_item.update_attributes(quantity: nil)
          line_item.direct_costs_for_one_time_fee.should eq(0) 
        end
      end

      context "indirect cost rate" do

        it "should return the correct indirect cost rate related to the line item" do
          line_item.indirect_cost_rate.should eq(2.0)
        end
      end

      context "indirect costs for visit based service single object" do

        it "should return the correct rate for a single subject" do
          line_item.indirect_costs_for_visit_based_service_single_subject.should eq(200)
        end
      end

      context "indirect costs for visit based service" do

        it "should return the correct indirect cost" do
          line_item.indirect_costs_for_visit_based_service.should eq(1000)
        end
      end

      context "indirect costs for one time fee" do

        it "should return the correct indirect cost" do
          pricing_map.update_attributes(is_one_time_fee: true)
          line_item.update_attributes(quantity: 10)
          line_item.indirect_costs_for_one_time_fee.should eq(400)
        end

        it "should return zero if the displayed pricing map is excluded from indirect costs" do
          pricing_map.update_attributes(is_one_time_fee: true, exclude_from_indirect_cost: true)
          line_item.indirect_costs_for_one_time_fee.should eq(0)
        end
      end
    end
  end

  context 'bulk creatable list' do
    let!(:service) { FactoryGirl.create(:service) }
    let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id) }
    let!(:line_item2) { FactoryGirl.create(:line_item, service_id: service.id) }

    describe 'bulk_create' do
      it 'should create 5 visits when passed n=5' do
        Visit.bulk_create(5, :line_item_id => line_item.id)
        line_item.visits.count.should eq 5
      end

      it 'should create visits with the right position' do
        Visit.bulk_create(5, :line_item_id => line_item.id)
        line_item.visits.count.should eq 5

        Visit.bulk_create(5, :line_item_id => line_item2.id)
        line_item2.visits.count.should eq 5

        Visit.bulk_create(5, :line_item_id => line_item.id)
        line_item.visits.count.should eq 10

        positions = line_item.visits.map { |visit| visit.position }
        positions.should eq [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
      end
    end
  end

end
