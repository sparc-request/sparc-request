require 'spec_helper'

describe Appointment do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  context "clinical work fulfillment" do

    let!(:core_18)       { FactoryGirl.create(:core) }
    let!(:appointment)  { FactoryGirl.create(:appointment, organization_id: core_18.id, completed_at: Date.today) }

    describe "completed for core" do

      it "should return true if the appointment is completed for a particular core" do
        appointment.completed_for_core?(core_18.id).should eq(true)
      end

      it "should return false if this is not the case" do
        appointment.completed_for_core?(core_17.id).should eq(false)
        appointment.update_attributes(completed_at: nil)
        appointment.completed_for_core?(core_18.id).should eq(false)
      end
    end
  end
end