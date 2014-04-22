require 'spec_helper'

describe 'SubServiceRequest' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  context 'clinical work fulfillment' do

    it 'should populate the subjects when :in_work_fulfillment is set to true' do
      sub_service_request.update_attributes(in_work_fulfillment: true)
      arm1.subjects.count.should eq(2)
      arm2.subjects.count.should eq(4)
    end

  end

  context 'fulfillment' do

    describe 'candidate_services' do

      context 'single core' do

        before :each do          
          @ppv = FactoryGirl.create(:service, organization_id: core.id) # PPV Service
          @otf = FactoryGirl.create(:service, organization_id: core.id) # OTF Service
          @otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))
          sub_service_request.update_attributes(organization_id: core.id)

          @ssr = sub_service_request
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
          core = FactoryGirl.create(:core, parent_id: program.id)
          core2 = FactoryGirl.create(:core, parent_id: program.id)
          core3 = FactoryGirl.create(:core, parent_id: program.id)
          
          ppv = FactoryGirl.create(:service, organization_id: core.id, name: "Per Patient Service") # PPV Service
          ppv2 = FactoryGirl.create(:service, :disabled, organization_id: core3.id) # Disabled PPV Service
          otf = FactoryGirl.create(:service, organization_id: core2.id, name: "OTF Service") # OTF Service
          otf.pricing_maps.build(FactoryGirl.attributes_for(:pricing_map, :is_one_time_fee))

          # ssr = FactoryGirl.create(:sub_service_request, organization_id: core.id)

          sub_service_request.candidate_services.should include(ppv, otf)
        end

      end

    end

    describe 'fulfillment line item manipulation' do

      let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
 
      context 'updating a line item' do

        it 'should fail if the line item is not on the sub service request' do
          lambda { sub_service_request2.update_line_item(line_item) }.should raise_exception
        end

        it 'should update the line item successfully' do
          sub_service_request.update_line_item(line_item, quantity: 50)
          line_item.quantity.should eq(50)
        end
      end

      context 'adding a line item' do

        before :each do
          @fulfillment_service = FactoryGirl.create(:service, organization_id: program.id)
          @fulfillment_service.pricing_maps.create(FactoryGirl.attributes_for(:pricing_map))
          @fulfillment_service.reload
        end

        it 'should create the line item' do
          li = sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id)
          li.service_id.should eq(@fulfillment_service.id)
          li.should_not be_new_record
        end

        context 'subject calendars exist' do

          before :each do
            add_visits
            service_request.arms.each(&:populate_subjects)
            sub_service_request.update_attribute(:in_work_fulfillment, true)
          end

          it 'should create procedures for the line item' do
            count = Procedure.count
            li = sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id)
            Procedure.count.should eq(count * 2)
          end

          it 'should roll back if it fails' do
            lambda {
              sub_service_request.stub(:in_work_fulfillment).and_raise('error')
              sub_service_request.create_line_item(service_id: @fulfillment_service.id, sub_service_request_id: sub_service_request.id) rescue nil
            }.should_not change(LineItem, :count)
          end

        end

      end
    end

    describe "cost calculations" do

      context "direct cost total" do

        it "should return the direct cost for services that are one time fees" do
          sub_service_request.direct_cost_total.should eq(5000)
        end

        it "should return the direct cost for services that are visit based" do
          pricing_map.update_attributes(is_one_time_fee: false)
          sub_service_request.direct_cost_total.should eq(0)
        end
      end

      context "indirect cost total" do

        it "should return the indirect cost for one time fees" do
          if USE_INDIRECT_COST
            sub_service_request.indirect_cost_total.should eq(1000)
          else
            sub_service_request.indirect_cost_total.should eq(0.0)
          end
        end

        it "should return the indirect cost for visit based services" do
          if USE_INDIRECT_COST
            sub_service_request.indirect_cost_total.should eq(1000)
          else
            sub_service_request.indirect_cost_total.should eq(0.0)
          end
        end
      end

      context "grand total" do

        it "should return the grand total cost of the sub service request" do
          if USE_INDIRECT_COST
            sub_service_request.grand_total.should eq(1500)
          else
            sub_service_request.grand_total.should eq(5000.0)
          end
        end
      end

      context 'effective date for cost calculations' do

        it "should use the effective pricing scheme if set" do
          sub_service_request.set_effective_date_for_cost_calculations
          sub_service_request.line_items.last.pricing_scheme.should eq('effective')
        end

        it "should use the display date if the pricing scheme is unset" do
          sub_service_request.set_effective_date_for_cost_calculations
          sub_service_request.unset_effective_date_for_cost_calculations
          sub_service_request.line_items.last.pricing_scheme.should eq('displayed')
        end
      end

      context "subsidy percentage" do

        it "should return the correct subsidy percentage" do
          sub_service_request.subsidy_percentage.should eq(50)
        end
      end

      context "subsidy organization" do

        let!(:subsidy_map2) { FactoryGirl.create(:subsidy_map, organization_id: program.id, max_dollar_cap: 100) }

        it "should return the core if max dollar cap or max percentage is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.organization.should eq(program)
        end
      end

      context "eligible for subsidy" do
        
        it "should return true if the organization's max dollar cap is > 0" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return true if the organization's max percentage is > 0" do
          subsidy_map.update_attributes(max_percentage: 50)
          sub_service_request.eligible_for_subsidy?.should eq(true)
        end

        it "should return false is organization is excluded from subsidy" do
          subsidy_map.update_attributes(max_dollar_cap: 100)
          excluded_funding_source = FactoryGirl.create(:excluded_funding_source, subsidy_map_id: subsidy_map.id, funding_source: "federal")
          sub_service_request.eligible_for_subsidy?.should eq(false)
        end
      end
    end

    describe "sub service request status" do

      context "can be edited" do

        it "should return true if the status is draft" do
          sub_service_request.update_attributes(status: "draft")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is submitted" do
          sub_service_request.update_attributes(status: "submitted")
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return true if the status is nil" do
          sub_service_request.update_attributes(status: nil)
          sub_service_request.can_be_edited?.should eq(true)
        end

        it "should return false if status is anything other than above states" do
          sub_service_request.update_attributes(status: "complete")
          sub_service_request.can_be_edited?.should eq(false)
        end
      end

      context "candidate statuses" do

        let!(:ctrc) do
          org = FactoryGirl.create(:provider)
          org.tag_list = "ctrc"
          org.save
          org 
        end
        let!(:provider) { FactoryGirl.create(:provider) }

        it "should contain 'ctrc approved' and 'ctrc review' if the organization is ctrc" do
          sub_service_request.update_attributes(organization_id: ctrc.id)
          sub_service_request.candidate_statuses.should include('ctrc approved', 'ctrc review')
        end

        it "should not contain ctrc statuses if the organization is not ctrc" do
          sub_service_request.update_attributes(organization_id: provider.id)
          sub_service_request.candidate_statuses.should_not include('ctrc approved', 'ctrc review')
        end 
      end
    end

    describe "sub service request ownership" do

      context "candidate owners" do
       
        let!(:user)               { FactoryGirl.create(:identity) }
     
        before :each do
          provider.update_attributes(process_ssrs: true)
          program.update_attributes(process_ssrs: true)
          core.update_attributes(process_ssrs: true)
        end

        it "should return all identities associated with the sub service request's organization, children, and parents" do
          sub_service_request.candidate_owners.should include(jug2)
        end

        it "should return the owner" do
          sub_service_request.update_attributes(owner_id: user.id)
          sub_service_request.candidate_owners.should include(user, jug2)
        end

        it "should not return the same identity twice if it is both the owner and service provider" do
          sub_service_request.update_attributes(owner_id: user.id)
          sub_service_request.candidate_owners.uniq.length.should eq(sub_service_request.candidate_owners.length) 
        end
      end
    end      
  end
end
