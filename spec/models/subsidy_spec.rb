require 'spec_helper'

describe "Subsidy" do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

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
