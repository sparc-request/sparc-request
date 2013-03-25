require 'spec_helper'

describe 'ServiceRequest' do
  describe "set visit page" do

    let!(:service_request)  { FactoryGirl.create(:service_request) }
    let!(:arm)              { FactoryGirl.create(:arm, :visit_count => 10)}

    it "should return 1 if arm visit count <= 5" do
      arm.update_attributes(visit_count: 0)
      service_request.set_visit_page(1, arm).should eq(1)
      arm.update_attributes(visit_count: 5)
      service_request.set_visit_page(1, arm).should eq(1)
    end

    it "should return 1 if there is the pages passed are <= 0" do
      service_request.set_visit_page(0, arm).should eq(1)
    end

    it "should return 1 if the pages passed are greater than the visit count divided by 5" do
      service_request.set_visit_page(3, arm).should eq(1)
    end

    it "should return the pages passed if above conditions are not true" do
      service_request.set_visit_page(2, arm).should eq(2)
    end
  end

  describe "identities" do

    let!(:institution)         { FactoryGirl.create(:institution) }
    let!(:provider)            { FactoryGirl.create(:provider, parent_id: institution.id, process_ssrs: true) }
    let!(:core)                { FactoryGirl.create(:core, parent_id: provider.id, process_ssrs: true) }
    let!(:program)             { FactoryGirl.create(:program, parent_id: core.id, process_ssrs: true)}
    let!(:service_request)     { FactoryGirl.create(:service_request) }
    let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, organization_id: core.id, service_request_id: service_request.id) }
    let!(:user1)               { FactoryGirl.create(:identity) }
    let!(:user2)               { FactoryGirl.create(:identity) }
    let!(:user3)               { FactoryGirl.create(:identity) }
    let!(:user4)               { FactoryGirl.create(:identity) }
    let!(:service_provider1)   { FactoryGirl.create(:service_provider, identity_id: user1.id, organization_id: core.id) }
    let!(:super_user)          { FactoryGirl.create(:super_user, identity_id: user2.id, organization_id: core.id)} 
    let!(:super_user2)         { FactoryGirl.create(:super_user, identity_id: user3.id, organization_id: provider.id)} 
    let!(:super_user3)         { FactoryGirl.create(:super_user, identity_id: user4.id, organization_id: program.id)} 

    context "relevant_service_providers_and_super_users" do

      it "should return all service providers and super users for related sub service requests" do
        service_request.relevant_service_providers_and_super_users.should include(user1, user2, user3, user4)
      end

      it "should not return any identities from child organizations if process ssrs is not set" do
        core.update_attributes(process_ssrs: false)
        service_request.relevant_service_providers_and_super_users.should_not include(user4)
      end
    end
  end

  describe "cost calculations" do

    let!(:core)            { FactoryGirl.create(:core) }
    let!(:pricing_setup)   { FactoryGirl.create(:pricing_setup, organization_id: core.id) } 
    let!(:service_request) { FactoryGirl.create(:service_request, subject_count: 5, visit_count: 5) }
    let!(:ssr)             { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:service)         { FactoryGirl.create(:service, organization_id: core.id) }
    let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id) }
    let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: ssr.id, service_id: service.id, subject_count: 5) }
    let!(:line_item2)      { FactoryGirl.create(:line_item, service_request_id: service_request.id, sub_service_request_id: ssr.id, service_id: service.id, subject_count: 5) }
    let!(:visit)           { FactoryGirl.create(:visit, line_item_id: line_item.id, research_billing_qty: 5) }
    let!(:visit2)          { FactoryGirl.create(:visit, line_item_id: line_item2.id, research_billing_qty: 5) }

    before :each do
      @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
      @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
      @protocol.save :validate => false
      service_request.update_attributes(protocol_id: @protocol.id)
      service_request.reload
    end

    context "total direct cost per patient" do

      it "should return the sum of all line items visit-based direct cost" do
        service_request.total_direct_costs_per_patient.should eq(5000)
      end
    end

    context "total indirect cost per patient" do

      it "should return the sum of all line items visit-based indirect cost" do
        if USE_INDIRECT_COST
          service_request.total_indirect_costs_per_patient.should eq(10000)
        else
          service_request.total_indirect_costs_per_patient.should eq(0.0)
        end
      end
    end

    context "total costs per patient" do

      it "should return the total of the direct and indirect costs" do
        if USE_INDIRECT_COST
          service_request.total_costs_per_patient.should eq(15000)
        else
          service_request.total_costs_per_patient.should eq(5000.0)
        end
      end
    end

    context "maximum direct costs per patient" do

      it "should return the maximum direct cost" do
        service_request.maximum_direct_costs_per_patient.should eq(1000)
      end
    end
  end
end
