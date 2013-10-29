require 'spec_helper'

describe Appointment do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  context "clinical work fulfillment" do

    let!(:appointment)  { FactoryGirl.create(:appointment) }


  
  end
end