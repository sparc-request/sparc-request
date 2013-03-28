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
    let!(:pricing_setup)   { FactoryGirl.create(:pricing_setup, organization_id: core.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
    let!(:service_request) { FactoryGirl.create(:service_request, status: "draft", start_date: Time.now, end_date: Time.now + 10.days) }
    let!(:ssr)             { FactoryGirl.create(:sub_service_request, ssr_id: "0001", service_request_id: service_request.id, organization_id: core.id)}
    let!(:service)         { FactoryGirl.create(:service, organization_id: core.id) }
    let!(:service2)        { FactoryGirl.create(:service, organization_id: core.id, name: 'Per Patient') }
    let!(:pricing_map)     { FactoryGirl.create(:pricing_map, service_id: service.id) }
    let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: ssr.id, quantity: 5, units_per_quantity: 1) }
    let!(:line_item2)      { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: ssr.id, quantity: 0) }
    let!(:arm1)            { FactoryGirl.create(:arm, name: "Arm", service_request_id: service_request.id, visit_count: 10, subject_count: 2)}
    let!(:arm2)            { FactoryGirl.create(:arm, name: "Arm2", service_request_id: service_request.id, visit_count: 5, subject_count: 4)}

    before :each do
      add_visits
      @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
      @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
      @protocol.save :validate => false
      service_request.update_attributes(protocol_id: @protocol.id)
      service_request.reload
    end

    context "total direct cost per patient" do

      it "should return the sum of all line items visit-based direct cost" do
        service_request.total_direct_costs_per_patient.should eq(10000)
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
          service_request.total_costs_per_patient.should eq(10000.0)
        end
      end
    end
  end
end
