require 'spec_helper'

describe 'SubServiceRequest' do

  context 'fulfillment' do

    describe 'candidate_services' do

      context 'single core' do

        before :each do
          program = FactoryGirl.create(:program)
          core = FactoryGirl.create(:core, :process_ssrs, parent_id: program.id)
          
          @ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          @otf = FactoryGirl.create(:service, organization_id: core.id) # OTF Service
          @otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))

          @ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)
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
          program = FactoryGirl.create(:program, :process_ssrs)
          core = FactoryGirl.create(:core, parent_id: program.id)
          core2 = FactoryGirl.create(:core, parent_id: program.id)
          core3 = FactoryGirl.create(:core, parent_id: program.id)
          
          ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: core3.id) # Disabled PPV Service
          otf = FactoryGirl.create(:service, organization_id: core2.id) # OTF Service
          otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))

          ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)

          ssr.candidate_services.should include(ppv, otf)
        end

      end

    end

    describe 'fulfillment line item manipulation' do

      let!(:core)                 { FactoryGirl.create(:core) }
      let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }
      let!(:service2)             { FactoryGirl.create(:service, organization_id: core.id) }
      let!(:service_request)      { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
      let!(:service_request2)     { FactoryGirl.create(:service_request) }
      let!(:sub_service_request)  { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id) }
      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request2.id) }
      let!(:pricing_map)          { FactoryGirl.create(:pricing_map, service_id: service.id) }
 
      context 'adding a line item' do
       
        it 'should fail if service is already on the service request' do
          FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          lambda { sub_service_request.add_line_item(service) }.should raise_exception
        end

        it 'should have added the line item if successful' do
          sub_service_request.add_line_item(service)
          service_request.line_items.count.should eq(1)
        end
      end

      context 'updating a line item' do

        it 'should fail if the line item is not on the sub service request' do
          FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          lambda { sub_service_request2.update_line_item(line_item) }.should raise_exception
        end

        it 'should update the line item successfully' do
          line_item = FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id,
            sub_service_request_id: sub_service_request.id)
          sub_service_request.update_line_item(line_item, quantity: 50)
          line_item.quantity.should eq(50)
        end
      end

      describe 'one time fee manipulation' do

        before :each do
          FactoryGirl.create(:pricing_map, :is_one_time_fee, service_id: service.id)
        end

        it 'should work with one time fees' do
          service.stub!(:is_one_time_fee?).and_return true
          lambda { sub_service_request.add_line_item(service) }.should_not raise_exception
        end
      end

      describe 'per patient per visit manipulation' do

        before :each do
          FactoryGirl.create(:pricing_map, service_id: service2.id)
        end

        context 'adding a line item' do

          it 'should build the visits successfully' do
            sr = ServiceRequest.find(service_request.id)
            sub_service_request.add_line_item(service2)
            sr.line_items.first.visits.count.should eq(service_request.visit_count)
          end
        end
      end
    end

    describe "cost calculations" do

      let!(:core)                 { FactoryGirl.create(:core) }
      let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }
      let!(:service2)             { FactoryGirl.create(:service, organization_id: core.id) }
      let!(:service_request)      { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
      let!(:service_request2)     { FactoryGirl.create(:service_request) }
      let!(:sub_service_request)  { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id) }
      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request2.id) }
      let!(:pricing_map)          { FactoryGirl.create(:pricing_map, service_id: service.id, is_one_time_fee: true)}
      let!(:pricing_map2)         { FactoryGirl.create(:pricing_map, service_id: service2.id)}
      let!(:line_item)            { FactoryGirl.create(:line_item, service_request_id: service_request2.id, sub_service_request_id: sub_service_request2.id,
                                   service_id: service.id) }
      let!(:line_item2)           { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: sub_service_request.id,
                                   service_id: service.id) }
      let!(:pricing_setup)        { FactoryGirl.create(:pricing_setup, organization_id: core.id) }
      let!(:subsidy)              { FactoryGirl.create(:subsidy, pi_contribution: 250, sub_service_request_id: sub_service_request.id) }
      
      before :each do
        @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
        @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
        @protocol.save :validate => false
        service_request.update_attributes(protocol_id: @protocol.id)
        service_request2.update_attributes(protocol_id: @protocol.id)
      end

      describe "direct cost total" do

        it "should return the direct cost for services that are one time fees" do
          sub_service_request2.direct_cost_total.should eq(500)
        end

        it "should return the direct cost for services that are visit based" do
          sub_service_request.direct_cost_total.should eq(500)
        end
      end

      describe "indirect cost total" do

        it "should return the indirect cost for one time fees" do
          sub_service_request2.indirect_cost_total.should eq(1000)
        end

        it "should return the indirect cost for visit based services" do
          sub_service_request.indirect_cost_total.should eq(1000)
        end
      end

      describe "grand total" do

        it "should return the grand total cost of the sub service request" do
          sub_service_request.grand_total.should eq(1500)
        end
      end

      describe "subsidy percentage" do

        it "should return the correct subsidy percentage" do
          sub_service_request.subsidy_percentage.should eq(50)
        end
      end
    end
  end
end
