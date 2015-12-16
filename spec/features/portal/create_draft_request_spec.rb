require 'rails_helper'

RSpec.describe 'creating a draft service request from user portal', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_empty_study


  scenario 'user adds services to empty protocol' do
    when_i_click_add_services
    then_a_draft_request_should_be_generated
  end

  scenario 'user adds services to a draft request without line items' do
    when_i_click_add_services
    when_i_click_add_services
    another_request_should_not_be_generated
  end

  def when_i_click_add_services
    visit portal_root_path
    @protocol = Protocol.last
    sleep 5
    sos
    find('.add-services-button').click
    wait_for_javascript_to_finish
  end

  def then_a_draft_request_should_be_generated
    wait_for_javascript_to_finish
    service_request = ServiceRequest.where(protocol_id: @protocol.id).first
    expect(service_request.status).to eq('draft')
  end

  def another_request_should_not_be_generated
    expect(@protocol.service_requests.count).to eq(1)
  end
end