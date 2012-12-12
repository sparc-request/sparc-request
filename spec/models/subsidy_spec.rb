require 'spec_helper'

describe "Subsidy" do

  let!(:core)                {FactoryGirl.create(:core)}
  let!(:service)             {FactoryGirl.create(:service, organization_id: core.id)}
  let!(:service_request)     {FactoryGirl.create(:service_request)}
  let!(:sub_service_request) {FactoryGirl.create(:sub_service_request, organization_id: core.id, service_request_id: service_request.id)}
  let!(:subsidy)             {FactoryGirl.create(:subsidy, pi_contribution: 2500, sub_service_request_id: sub_service_request.id)}
  let!(:line_item)           {FactoryGirl.create(:line_item, service_request_id: service_request.id,
                              sub_service_request_id: sub_service_request.id, service_id: service.id, quantity: 50)}
  let!(:pricing_map)         {FactoryGirl.create(:pricing_map, service_id: service.id, unit_factor: 1, percent_of_fee: 0,
                              is_one_time_fee: true, full_rate: 100, exclude_from_indirect_cost: true, unit_minimum: 1,
                              federal_rate: 100, corporate_rate: 100)}
  let!(:pricing_setup)       {FactoryGirl.create(:pricing_setup, organization_id: core.id)}
  
  before :each do
    @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    @protocol.update_attributes(funding_status: "funded", funding_source: "federal", indirect_cost_rate: 100)
    @protocol.save :validate => false
    service_request.update_attributes(protocol_id: @protocol.id)
  end

  describe "percent subsidy" do

    it "should return the correct subsidy" do
      subsidy.percent_subsidy.should eq(0.5)
    end

    it "should return 100% subsidy if there is no pi contribution" do
      subsidy.update_attributes(pi_contribution: 0)
      subsidy.percent_subsidy.should eq(1.0)
    end

    it "should return zero if pi contribution is nil" do
      subsidy.update_attributes(pi_contribution: nil)
      subsidy.percent_subsidy.should eq(0.0)
    end
  end

  describe "fix pi contribution" do

    it "should set the pi contribution from a given subsidy percentage" do
      subsidy.fix_pi_contribution(50)
      subsidy.pi_contribution.should eq(2500)
    end
  end
end
