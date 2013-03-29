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

  context "methods" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_project

    before :each do
      add_visits
    end

    describe "one time fee line items" do
      it "should return one time fee line items" do
        service_request.one_time_fee_line_items[0].service.name.should eq("One Time Fee")
      end
    end
    describe "has one time fee services" do
      it "should return true" do
        service_request.has_one_time_fee_services?.should eq(true)
      end
    end
    describe "has per patient per visit services" do
      it "should return true" do
        service_request.has_per_patient_per_visit_services?.should eq(true)
      end
    end
    # describe "servcie list" do
    #   it "should do stuff" do
    #     service_request.service_list.should eq(3)
    #   end
    # end
  end

  describe "cost calculations" do
    let_there_be_lane
    let_there_be_j
    build_service_request_with_project
    #USE_INDIRECT_COST = true  #For testing indirect cost

    before :each do
      add_visits
      @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
      @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 200)
      @protocol.save :validate => false
      service_request.update_attributes(protocol_id: @protocol.id)
      service_request.reload
    end

    context "total direct cost one time" do
      it "should return the sum of all line items one time fee direct cost" do
        service_request.total_direct_costs_one_time.should eq(5000)
      end
    end
    context "total indirect cost one time" do
      it "should return the sum of all line items one time fee indirect cost" do
        if USE_INDIRECT_COST
          service_request.total_indirect_costs_one_time.should eq(10000)
        else
          service_request.total_indirect_costs_one_time.should eq(0.0)
        end
      end
    end

    context "total cost one time" do
      it "should return the sum of all line items one time fee direct and indirect costs" do
        if USE_INDIRECT_COST
          service_request.total_costs_one_time.should eq(15000)
        else
          service_request.total_costs_one_time.should eq(5000)
        end
      end
    end

    context "total direct cost" do
      it "should return the sum of all line items direct cost" do
        service_request.direct_cost_total.should eq(605000)
      end
    end

    context "total indirect cost" do
      it "should return the sum of all line items indirect cost" do
        if USE_INDIRECT_COST
          service_request.indirect_cost_total.should eq(1210000)
        else
          service_request.indirect_cost_total.should eq(0.0)
        end
      end
    end

    context "grand total" do
      it "should return the grand total of all costs" do
        if USE_INDIRECT_COST
          service_request.grand_total.should eq(1815000)
        else
          service_request.grand_total.should eq(605000)
        end
      end
    end

    context "total direct cost per patient" do

      it "should return the sum of all line items visit-based direct cost" do
        service_request.total_direct_costs_per_patient.should eq(600000)
      end
    end

    context "total indirect cost per patient" do

      it "should return the sum of all line items visit-based indirect cost" do
        if USE_INDIRECT_COST
          service_request.total_indirect_costs_per_patient.should eq(1200000)
        else
          service_request.total_indirect_costs_per_patient.should eq(0.0)
        end
      end
    end

    context "total costs per patient" do

      it "should return the total of the direct and indirect costs" do
        if USE_INDIRECT_COST
          service_request.total_costs_per_patient.should eq(1800000)
        else
          service_request.total_costs_per_patient.should eq(600000.0)
        end
      end
    end
  end
end
