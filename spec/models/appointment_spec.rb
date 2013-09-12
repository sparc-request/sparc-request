require 'spec_helper'

describe Appointment do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  let!(:core_17)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_13)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_16)      { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core_15)      { FactoryGirl.create(:core, parent_id: program.id) }

  before :each do
    core_17.tag_list.add("nutrition")
    core_13.tag_list.add("nursing")
    core_16.tag_list.add("laboratory")
    core_15.tag_list.add("imaging")
    core_17.save
    core_13.save
    core_16.save
    core_15.save
  end

  context "clinical work fulfillment" do

    let!(:appointment)  { FactoryGirl.create(:appointment) }

    # should already be 4 competions because of the 'before create' action
    it 'should be possible to create an appointment' do
      appt = Appointment.create!()
      appt.appointment_completions.size.should eq (4)
    end

    describe "creating appointment completions" do

      # should be 8 completions if the method is called again
      it "should create a appointment completion for each cwf core" do
        appointment.create_appointment_completions
        appointment.appointment_completions.size.should eq(8)
      end
    end
  end
end