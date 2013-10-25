require 'spec_helper'

describe Appointment do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  context "clinical work fulfillment" do

    let!(:appointment)  { FactoryGirl.create(:appointment) }

    # should already be 5 competions because of the 'before create' action
    it 'should be possible to create an appointment' do
      appt = Appointment.create!()
      appt.appointment_completions.size.should eq(5)
    end

    describe "creating appointment completions" do

      # should be 10 completions if the method is called again
      it "should create a appointment completion for each cwf core" do
        appointment.create_appointment_completions
        appointment.appointment_completions.size.should eq(10)
      end
    end
  end
end