require 'spec_helper'

describe "study level charges", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits    
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "entering fulfillment information" do

    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "Study Level Charges"
    end

    it 'should successfully add a subsidy' do
      find('.add_nested_fields', visible: true).click
      wait_for_javascript_to_finish
      page.should have_content('Date')
    end
  end
end