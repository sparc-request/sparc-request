require 'spec_helper'

describe "VisitGroup" do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  let!(:visit_group)         { FactoryGirl.create(:visit_group, arm_id: arm1.id, position: 1, day: 1)}

  context "setting the default name" do

    it "should set a default name based on its position" do
      visit_group.name.should eq("Visit 1")
    end

    it "should not set the name if it already has one" do
      visit_group.update_attributes(name: "Foobar")
      visit_group.set_default_name
      visit_group.name.should eq("Foobar")
    end
  end
end
