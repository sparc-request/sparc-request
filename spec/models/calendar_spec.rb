require 'spec_helper'

describe Calendar do
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  it "should have created a calendar when the subjects were created" do
    arm1.populate_subjects
    arm1.subjects.first.calendar.should_not eq(nil)
  end

  before :each do
    add_visits
  end

  describe 'populate' do

    it "should populate a subject with appointments and procedures" do
      arm1.populate_subjects
      calendar = arm1.subjects.first.calendar
      calendar.populate(arm1.visit_groups)
      calendar.appointments.should_not eq([])
    end
  end
end