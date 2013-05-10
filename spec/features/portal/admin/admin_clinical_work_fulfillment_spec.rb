require 'spec_helper'

describe 'clinical work fulfillment', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    page.find('.clinical_work_fulfillment-tab').click
  end

  context "clicking clinical work fulfilment tab" do

    it "should make the sub-tabs visible" do
      find('.subject_tracker-tab').should be_visible
    end
  end

end